/* -*-  Mode: C++; c-file-style: "gnu"; indent-tabs-mode:nil; -*- */
/*
 * Copyright (c) 2005,2006,2007 INRIA
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License version 2 as
 * published by the Free Software Foundation;
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 *
 * Author: Mathieu Lacage <mathieu.lacage@sophia.inria.fr>
 */

//
// This is an illustration of how one could use virtualization techniques to
// allow running applications on virtual machines talking over simulated
// networks.
//
// The actual steps required to configure the virtual machines can be rather
// involved, so we don't go into that here.  Please have a look at one of
// our HOWTOs on the nsnam wiki for more details about how to get the 
// system confgured.  For an example, have a look at "HOWTO Use Linux 
// Containers to set up virtual networks" which uses this code as an 
// example.
//
// The configuration you are after is explained in great detail in the 
// HOWTO, but looks like the following:
//
//  +----------+                           +----------+
//  | virtual  |                           | virtual  |
//  |  Linux   |                           |  Linux   |
//  |   Host   |                           |   Host   |
//  |          |                           |          |
//  |   eth0   |                           |   eth0   |
//  +----------+                           +----------+
//       |                                      |
//  +----------+                           +----------+
//  |  Linux   |                           |  Linux   |
//  |  Bridge  |                           |  Bridge  |
//  +----------+                           +----------+
//       |                                      |
//  +------------+                       +-------------+
//  | "tap-left" |                       | "tap-right" |
//  +------------+                       +-------------+
//       |           n0            n1           |
//       |       +--------+    +--------+       |
//       +-------|  tap   |    |  tap   |-------+
//               | bridge |    | bridge |
//               +--------+    +--------+
//               |  wifi  |    |  wifi  |
//               +--------+    +--------+
//                   |             |
//                 ((*))         ((*))
//
//                       NS3 MANET
//
// cp manet-2015.cc /opt/tools/network_simulators/ns3/ns-allinone-3.25/ns-3.25/scratch/
// ./waf --run scratch/manet-2015 --vis
// rm *.tr *.pcap *.xml

#include <iostream>
#include <fstream>

#include "ns3/core-module.h"
#include "ns3/network-module.h"
#include "ns3/applications-module.h"
#include "ns3/mobility-module.h"
#include "ns3/stats-module.h"
#include "ns3/wifi-module.h"
#include "ns3/internet-module.h"
#include "ns3/olsr-module.h"
#include "ns3/netanim-module.h"

#include "ns3/tap-bridge-module.h"

NS_LOG_COMPONENT_DEFINE ("MANET");

using namespace ns3;

// Simulation parameters
int nodeSpacing = 100; // meters
int cols = 5;
//int numNodes = 25;
int numNodes = 5;
int sourceNode = 0;
int destinationNode = 24;
int packetRate = 20; // packet per second
int packetSize = 500; // bytes
bool enablePcap = true;
bool showSimTime = true;
int duration = 600; // seconds
int seed = 1;
int run = 1;

// To show simulated time. Sent to STDERR to separation
// from other output (e.g., visualization trace)
void PrintSeconds(void) {
	std::cerr << Simulator::Now() << std::endl;
	Simulator::Schedule(Seconds(1), &PrintSeconds);
}

void RouteChange(std::string source, uint32_t size) {
	std::cout << "Routechange at " << source << ", new size: " << size << std::endl;
}

int main (int argc, char *argv[])
{
  LogComponentEnable ("MANET", LOG_LEVEL_INFO);

  // Obtain command line arguments
  CommandLine cmd;
  cmd.AddValue ("cols", "Columns of nodes", cols);
  cmd.AddValue ("numnodes", "Number of nodes", numNodes);
  cmd.AddValue ("spacing", "Spacing between neighbouring nodes", nodeSpacing);
  cmd.AddValue ("duration", "Duration of simulation", duration);
  cmd.AddValue ("seed", "Random seed for simulation", seed);
  cmd.AddValue ("run", "Simulation run", run);
  cmd.AddValue ("packetrate", "Packets transmitted per second", packetRate);
  cmd.AddValue ("packetsize", "Packet size", packetSize);
  cmd.AddValue ("sourcenode", "Number of source node", sourceNode);
  cmd.AddValue ("destinationnode", "Number of destination node", destinationNode);
  cmd.AddValue ("showtime", "Whether or not to show simulation as simulation progresses (default = true)", showSimTime);
  cmd.Parse (argc,argv);

  int rows = ((int) numNodes / cols) + 1;

  // Set default parameter values
  Config::SetDefault("ns3::WifiRemoteStationManager::FragmentationThreshold", StringValue ("2200"));
  Config::SetDefault ("ns3::WifiRemoteStationManager::RtsCtsThreshold", StringValue ("2200"));

  //
  // We are interacting with the outside, real, world.  This means we have to 
  // interact in real-time and therefore means we have to use the real-time
  // simulator and take the time to calculate checksums.
  //
  // if use the two following lines, then, "./waf --run scratch/manet-2015 --vis", can not show the GUI
//  GlobalValue::Bind ("SimulatorImplementationType", StringValue ("ns3::RealtimeSimulatorImpl"));
//  GlobalValue::Bind ("ChecksumEnabled", BooleanValue (true));

  // Set random seed and run number
  SeedManager::SetSeed (seed);
  SeedManager::SetRun(run);

  //
  // Create two ghost nodes.  The first will represent the virtual machine host
  // on the left side of the network; and the second will represent the VM on 
  // the right side.
  //
  // Create notes
  NodeContainer nodes;
  nodes.Create (numNodes);

  //
  // We're going to use 802.11 g so set up a wifi helper to reflect that.
  //
  // Set up physical and mac layers
  WifiHelper wifi = WifiHelper::Default ();
  wifi.SetStandard (WIFI_PHY_STANDARD_80211g);
  wifi.SetRemoteStationManager ("ns3::ArfWifiManager");

  //
  // No reason for pesky access points, so we'll use an ad-hoc network.
  //
  NqosWifiMacHelper wifiMac = NqosWifiMacHelper::Default ();
  wifiMac.SetType ("ns3::AdhocWifiMac");

  //
  // Configure the physcial layer.
  //
  YansWifiChannelHelper wifiChannel = YansWifiChannelHelper::Default ();
  YansWifiPhyHelper wifiPhy = YansWifiPhyHelper::Default ();
  wifiPhy.SetChannel (wifiChannel.Create ());

  //
  // Install the wireless devices onto our ghost nodes.
  //
  NetDeviceContainer devices = wifi.Install (wifiPhy, wifiMac, nodes);

  if(enablePcap)
	  wifiPhy.EnablePcap ("MANET", devices);

  // Set up routing and Internet stack
  ns3::OlsrHelper olsr;
  InternetStackHelper internet;
  internet.SetRoutingHelper(olsr);
  internet.Install (nodes);

  // Assign addresses
  Ipv4AddressHelper address;
  address.SetBase ("10.0.0.0", "255.255.255.0");
  Ipv4InterfaceContainer interfaces = address.Assign (devices);

  // Server/Receiver
  UdpServerHelper server (4000);
  ApplicationContainer apps = server.Install (nodes.Get(destinationNode));
  apps.Start (Seconds (1));
  apps.Stop (Seconds (duration - 1));

  // Client/Sender
  UdpClientHelper client (interfaces.GetAddress (destinationNode), 4000);
  client.SetAttribute ("MaxPackets", UintegerValue (100000000));
  client.SetAttribute ("Interval", TimeValue (Seconds(1 / ((double) packetRate))));
  client.SetAttribute ("PacketSize", UintegerValue (packetSize));
  apps = client.Install (nodes.Get (sourceNode));
  apps.Start (Seconds (1));
  apps.Stop (Seconds (duration - 1));

  //
  // We need location information since we are talking about wifi, so add a
  // constant position to the ghost nodes.
  //
  // Set up mobility
  MobilityHelper mobility;
  mobility.SetPositionAllocator (
		  "ns3::GridPositionAllocator",
		  "MinX", DoubleValue (1.0),
		  "MinY", DoubleValue (1.0),
		  "DeltaX", DoubleValue (nodeSpacing),
		  "DeltaY", DoubleValue (nodeSpacing),
		  "GridWidth", UintegerValue (cols));

  mobility.SetMobilityModel (
		  "ns3::RandomWalk2dMobilityModel",
		  "Bounds", RectangleValue (Rectangle (0,(cols * nodeSpacing) + 1, 0,(rows * nodeSpacing) + 1)),
		  "Speed", StringValue("ns3::UniformRandomVariable[Min=5.0,Max=10.0]"),
		  "Distance", DoubleValue(30));

  mobility.Install (nodes);

  // Schedule final events and start simulation

  // Print simulated time
  if(showSimTime)
    Simulator::Schedule(Seconds(1), &PrintSeconds);

  //
  // Use the TapBridgeHelper to connect to the pre-configured tap devices for 
  // the left side.  We go with "UseBridge" mode since the CSMA devices support
  // promiscuous mode and can therefore make it appear that the bridge is 
  // extended into ns-3.  The install method essentially bridges the specified
  // tap to the specified CSMA device.
  //
  TapBridgeHelper tapBridge;
  tapBridge.SetAttribute ("Mode", StringValue ("UseLocal"));
  //tapBridge.SetAttribute ("Mode", StringValue ("UseBridge"));

  tapBridge.SetAttribute ("DeviceName", StringValue ("tap_a_1"));
  tapBridge.Install (nodes.Get (0), devices.Get (0));

  tapBridge.SetAttribute ("DeviceName", StringValue ("tap_a_2"));
  tapBridge.Install (nodes.Get (1), devices.Get (1));

  tapBridge.SetAttribute ("DeviceName", StringValue ("tap_a_3"));
  tapBridge.Install (nodes.Get (2), devices.Get (2));

  tapBridge.SetAttribute ("DeviceName", StringValue ("tap_a_4"));
  tapBridge.Install (nodes.Get (3), devices.Get (3));

  tapBridge.SetAttribute ("DeviceName", StringValue ("tap_a_5"));
  tapBridge.Install (nodes.Get (4), devices.Get (4));

  //
  // Run the simulation for ten minutes to give the user time to play around
  //
  Simulator::Stop(Seconds(duration));
  Simulator::Run ();
  Simulator::Destroy ();

  return 0;
}
