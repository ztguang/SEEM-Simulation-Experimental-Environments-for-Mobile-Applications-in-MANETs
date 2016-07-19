/* -*-  Mode: C++; c-file-style: "gnu"; indent-tabs-mode:nil; -*- */
/*
 * Copyright (c) 2009 University of Washington
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
 */

//
// This program configures a grid (default 5x5) of nodes on an 
// 802.11b physical layer, with
// 802.11b NICs in adhoc mode, and by default, sends one packet of 1000 
// (application) bytes to node 1.
//
// The default layout is like this, on a 2-D grid.
//
// n20  n21  n22  n23  n24
// n15  n16  n17  n18  n19
// n10  n11  n12  n13  n14
// n5   n6   n7   n8   n9
// n0   n1   n2   n3   n4
//
// the layout is affected by the parameters given to GridPositionAllocator;
// by default, GridWidth is 5 and numNodes is 25..
//
// There are a number of command-line options available to control
// the default behavior.  The list of available command-line options
// can be listed with the following command:
// ./waf --run "wifi-simple-adhoc-grid --help"
//
// Note that all ns-3 attributes (not just the ones exposed in the below
// script) can be changed at command line; see the ns-3 documentation.
//
// For instance, for this configuration, the physical layer will
// stop successfully receiving packets when distance increases beyond
// the default of 500m.
// To see this effect, try running:
//
// ./waf --run "wifi-simple-adhoc --distance=500"
// ./waf --run "wifi-simple-adhoc --distance=1000"
// ./waf --run "wifi-simple-adhoc --distance=1500"
// 
// The source node and sink node can be changed like this:
// 
// ./waf --run "wifi-simple-adhoc --sourceNode=20 --sinkNode=10"
//
// This script can also be helpful to put the Wifi layer into verbose
// logging mode; this command will turn on all wifi logging:
// 
// ./waf --run "wifi-simple-adhoc-grid --verbose=1"
//
// By default, trace file writing is off-- to enable it, try:
// ./waf --run "wifi-simple-adhoc-grid --tracing=1"
//
// When you are done tracing, you will notice many pcap trace files 
// in your directory.  If you have tcpdump installed, you can try this:
//
// tcpdump -r wifi-simple-adhoc-grid-0-0.pcap -nn -tt
//

#include "ns3/core-module.h"
#include "ns3/network-module.h"
#include "ns3/mobility-module.h"
#include "ns3/config-store-module.h"
#include "ns3/wifi-module.h"
//#include "ns3/internet-module.h"
//#include "ns3/olsr-helper.h"
//#include "ns3/ipv4-static-routing-helper.h"
//#include "ns3/ipv4-list-routing-helper.h"

#include "ns3/tap-bridge-module.h"

#include <iostream>
#include <fstream>
#include <vector>
#include <string>

using namespace ns3;

NS_LOG_COMPONENT_DEFINE ("WifiSimpleAdhocGrid");

void ReceivePacket (Ptr<Socket> socket)
{
  while (socket->Recv ())
    {
      NS_LOG_UNCOND ("Received one packet!");
    }
}

static void GenerateTraffic (Ptr<Socket> socket, uint32_t pktSize, 
                             uint32_t pktCount, Time pktInterval )
{
  if (pktCount > 0)
    {
      socket->Send (Create<Packet> (pktSize));
      Simulator::Schedule (pktInterval, &GenerateTraffic, 
                           socket, pktSize,pktCount-1, pktInterval);
    }
  else
    {
      socket->Close ();
    }
}


int main (int argc, char *argv[])
{
  std::string phyMode ("DsssRate1Mbps");
  double distance = 500;  // m
  uint32_t packetSize = 1000; // bytes
  uint32_t numPackets = 1;
  uint32_t numNodes = 25;  // by default, 5x5
  uint32_t sinkNode = 0;
  uint32_t sourceNode = 24;
  double interval = 1.0; // seconds
  bool verbose = false;
  bool tracing = false;

  //int nodeSpeed = 20; //in m/s
  int nodeSpeed = 1; //in m/s
  int nodePause = 0; //in s

  CommandLine cmd;

  cmd.AddValue ("phyMode", "Wifi Phy mode", phyMode);
  cmd.AddValue ("distance", "distance (m)", distance);
  cmd.AddValue ("packetSize", "size of application packet sent", packetSize);
  cmd.AddValue ("numPackets", "number of packets generated", numPackets);
  cmd.AddValue ("interval", "interval (seconds) between packets", interval);
  cmd.AddValue ("verbose", "turn on all WifiNetDevice log components", verbose);
  cmd.AddValue ("tracing", "turn on ascii and pcap tracing", tracing);
  cmd.AddValue ("numNodes", "number of nodes", numNodes);
  cmd.AddValue ("sinkNode", "Receiver node number", sinkNode);
  cmd.AddValue ("sourceNode", "Sender node number", sourceNode);

  cmd.Parse (argc, argv);
  // Convert to time object
  Time interPacketInterval = Seconds (interval);

  // disable fragmentation for frames below 2200 bytes
  Config::SetDefault ("ns3::WifiRemoteStationManager::FragmentationThreshold", StringValue ("2200"));
  // turn off RTS/CTS for frames below 2200 bytes
  Config::SetDefault ("ns3::WifiRemoteStationManager::RtsCtsThreshold", StringValue ("2200"));
  // Fix non-unicast data rate to be the same as that of unicast
  Config::SetDefault ("ns3::WifiRemoteStationManager::NonUnicastMode", 
                      StringValue (phyMode));

  NodeContainer adhocNodes;
  adhocNodes.Create (numNodes);

  // The below set of helpers will help us to put together the wifi NICs we want
  WifiHelper wifi;
  if (verbose)
    {
      wifi.EnableLogComponents ();  // Turn on all Wifi logging
    }

  YansWifiPhyHelper wifiPhy =  YansWifiPhyHelper::Default ();
  // set it to zero; otherwise, gain will be added
  wifiPhy.Set ("RxGain", DoubleValue (-10) ); 
  // ns-3 supports RadioTap and Prism tracing extensions for 802.11b
  wifiPhy.SetPcapDataLinkType (YansWifiPhyHelper::DLT_IEEE802_11_RADIO); 

  YansWifiChannelHelper wifiChannel;
  wifiChannel.SetPropagationDelay ("ns3::ConstantSpeedPropagationDelayModel");
  wifiChannel.AddPropagationLoss ("ns3::FriisPropagationLossModel");
  wifiPhy.SetChannel (wifiChannel.Create ());

  // Add an upper mac and disable rate control
  WifiMacHelper wifiMac;
  wifi.SetStandard (WIFI_PHY_STANDARD_80211b);
  wifi.SetRemoteStationManager ("ns3::ConstantRateWifiManager",
                                "DataMode",StringValue (phyMode),
                                "ControlMode",StringValue (phyMode));
  // Set it to adhoc mode
  wifiMac.SetType ("ns3::AdhocWifiMac");
  NetDeviceContainer adhocDevices = wifi.Install (wifiPhy, wifiMac, adhocNodes);

/*
  MobilityHelper mobility;
  mobility.SetPositionAllocator ("ns3::GridPositionAllocator",
                                 "MinX", DoubleValue (0.0),
                                 "MinY", DoubleValue (0.0),
                                 "DeltaX", DoubleValue (distance),
                                 "DeltaY", DoubleValue (distance),
                                 "GridWidth", UintegerValue (5),
                                 "LayoutType", StringValue ("RowFirst"));
  mobility.SetMobilityModel ("ns3::ConstantPositionMobilityModel");
  mobility.Install (adhocNodes);
*/
//----------------------------------------------------------------------
  MobilityHelper mobilityAdhoc;
  int64_t streamIndex = 0; // used to get consistent mobility across scenarios

  ObjectFactory pos;
  pos.SetTypeId ("ns3::RandomRectanglePositionAllocator");
  pos.Set ("X", StringValue ("ns3::UniformRandomVariable[Min=0.0|Max=300.0]"));
  pos.Set ("Y", StringValue ("ns3::UniformRandomVariable[Min=0.0|Max=1500.0]"));

  Ptr<PositionAllocator> taPositionAlloc = pos.Create ()->GetObject<PositionAllocator> ();
  streamIndex += taPositionAlloc->AssignStreams (streamIndex);

  std::stringstream ssSpeed;
  ssSpeed << "ns3::UniformRandomVariable[Min=0.0|Max=" << nodeSpeed << "]";
  std::stringstream ssPause;
  ssPause << "ns3::ConstantRandomVariable[Constant=" << nodePause << "]";
  mobilityAdhoc.SetMobilityModel ("ns3::RandomWaypointMobilityModel",
                                  "Speed", StringValue (ssSpeed.str ()),
                                  "Pause", StringValue (ssPause.str ()),
                                  "PositionAllocator", PointerValue (taPositionAlloc));
  //mobilityAdhoc.SetPositionAllocator (taPositionAlloc);
  mobilityAdhoc.SetPositionAllocator ("ns3::GridPositionAllocator",
                                 "MinX", DoubleValue (0.0),
                                 "MinY", DoubleValue (0.0),
                                 "DeltaX", DoubleValue (distance),
                                 "DeltaY", DoubleValue (distance),
                                 "GridWidth", UintegerValue (5),
                                 "LayoutType", StringValue ("RowFirst"));

  mobilityAdhoc.Install (adhocNodes);
  streamIndex += mobilityAdhoc.AssignStreams (adhocNodes, streamIndex);
//----------------------------------------------------------------------


/*
  // Enable OLSR
  OlsrHelper olsr;
  Ipv4StaticRoutingHelper staticRouting;

  Ipv4ListRoutingHelper list;
  list.Add (staticRouting, 0);
  list.Add (olsr, 10);

  InternetStackHelper internet;
  internet.SetRoutingHelper (list); // has effect on the next Install ()
  internet.Install (adhocNodes);

  Ipv4AddressHelper ipv4;
  NS_LOG_INFO ("Assign IP Addresses.");
  ipv4.SetBase ("10.1.1.0", "255.255.255.0");
  Ipv4InterfaceContainer i = ipv4.Assign (adhocDevices);

  TypeId tid = TypeId::LookupByName ("ns3::UdpSocketFactory");
  Ptr<Socket> recvSink = Socket::CreateSocket (adhocNodes.Get (sinkNode), tid);
  InetSocketAddress local = InetSocketAddress (Ipv4Address::GetAny (), 80);
  recvSink->Bind (local);
  recvSink->SetRecvCallback (MakeCallback (&ReceivePacket));

  Ptr<Socket> source = Socket::CreateSocket (adhocNodes.Get (sourceNode), tid);
  InetSocketAddress remote = InetSocketAddress (i.GetAddress (sinkNode, 0), 80);
  source->Connect (remote);

  if (tracing == true)
    {
      AsciiTraceHelper ascii;
      wifiPhy.EnableAsciiAll (ascii.CreateFileStream ("wifi-simple-adhoc-grid.tr"));
      wifiPhy.EnablePcap ("wifi-simple-adhoc-grid", adhocDevices);
      // Trace routing tables
      Ptr<OutputStreamWrapper> routingStream = Create<OutputStreamWrapper> ("wifi-simple-adhoc-grid.routes", std::ios::out);
      olsr.PrintRoutingTableAllEvery (Seconds (2), routingStream);
      Ptr<OutputStreamWrapper> neighborStream = Create<OutputStreamWrapper> ("wifi-simple-adhoc-grid.neighbors", std::ios::out);
      olsr.PrintNeighborCacheAllEvery (Seconds (2), neighborStream);

      // To do-- enable an IP-level trace that shows forwarding events only
    }

  // Give OLSR time to converge-- 30 seconds perhaps
  Simulator::Schedule (Seconds (30.0), &GenerateTraffic, 
                       source, packetSize, numPackets, interPacketInterval);

  // Output what we are doing
  NS_LOG_UNCOND ("Testing from node " << sourceNode << " to " << sinkNode << " with grid distance " << distance);

*/

  //----------------------------------------------------------------------------------------------------
  // Use the TapBridgeHelper to connect to the pre-configured tap devices for 
  // the left side.  We go with "UseBridge" mode since the CSMA devices support
  // promiscuous mode and can therefore make it appear that the bridge is 
  // extended into ns-3.  The install method essentially bridges the specified
  // tap to the specified CSMA device.
  //
  TapBridgeHelper tapBridge;
  tapBridge.SetAttribute ("Mode", StringValue ("UseLocal"));
  //tapBridge.SetAttribute ("Mode", StringValue ("UseBridge"));

  //tapBridge.SetAttribute ("Gateway", Ipv4AddressValue ("10.1.1.1"));
  //tapBridge.SetAttribute ("DeviceName", StringValue ("tap_a_1"));
  //tapBridge.Install (adhocNodes.Get (0), adhocDevices.Get (0));
  //tapBridge.SetAttribute ("Gateway", Ipv4AddressValue ("10.1.1.2"));
  //tapBridge.SetAttribute ("DeviceName", StringValue ("tap_a_2"));
  //tapBridge.Install (adhocNodes.Get (1), adhocDevices.Get (1));
  //Add New Lines via sed
  //sed -i '256a \\n  tapBridge.Install (adhocNodes.Get (1), adhocDevices.Get (1));\n  newline;' manet-seem-template.cc

  tapBridge.SetAttribute ("DeviceName", StringValue ("tap_d_1"));
  tapBridge.Install (adhocNodes.Get (0), adhocDevices.Get (0));
  tapBridge.SetAttribute ("DeviceName", StringValue ("tap_d_2"));
  tapBridge.Install (adhocNodes.Get (1), adhocDevices.Get (1));
  tapBridge.SetAttribute ("DeviceName", StringValue ("tap_d_3"));
  tapBridge.Install (adhocNodes.Get (2), adhocDevices.Get (2));
  tapBridge.SetAttribute ("DeviceName", StringValue ("tap_d_4"));
  tapBridge.Install (adhocNodes.Get (3), adhocDevices.Get (3));
  tapBridge.SetAttribute ("DeviceName", StringValue ("tap_d_5"));
  tapBridge.Install (adhocNodes.Get (4), adhocDevices.Get (4));
  tapBridge.SetAttribute ("DeviceName", StringValue ("tap_d_6"));
  tapBridge.Install (adhocNodes.Get (5), adhocDevices.Get (5));
  tapBridge.SetAttribute ("DeviceName", StringValue ("tap_d_7"));
  tapBridge.Install (adhocNodes.Get (6), adhocDevices.Get (6));
  tapBridge.SetAttribute ("DeviceName", StringValue ("tap_d_8"));
  tapBridge.Install (adhocNodes.Get (7), adhocDevices.Get (7));
  tapBridge.SetAttribute ("DeviceName", StringValue ("tap_d_9"));
  tapBridge.Install (adhocNodes.Get (8), adhocDevices.Get (8));
  tapBridge.SetAttribute ("DeviceName", StringValue ("tap_d_10"));
  tapBridge.Install (adhocNodes.Get (9), adhocDevices.Get (9));
  tapBridge.SetAttribute ("DeviceName", StringValue ("tap_d_11"));
  tapBridge.Install (adhocNodes.Get (10), adhocDevices.Get (10));
  tapBridge.SetAttribute ("DeviceName", StringValue ("tap_d_12"));
  tapBridge.Install (adhocNodes.Get (11), adhocDevices.Get (11));
  tapBridge.SetAttribute ("DeviceName", StringValue ("tap_d_13"));
  tapBridge.Install (adhocNodes.Get (12), adhocDevices.Get (12));
  tapBridge.SetAttribute ("DeviceName", StringValue ("tap_d_14"));
  tapBridge.Install (adhocNodes.Get (13), adhocDevices.Get (13));
  tapBridge.SetAttribute ("DeviceName", StringValue ("tap_d_15"));
  tapBridge.Install (adhocNodes.Get (14), adhocDevices.Get (14));
  tapBridge.SetAttribute ("DeviceName", StringValue ("tap_d_16"));
  tapBridge.Install (adhocNodes.Get (15), adhocDevices.Get (15));
  tapBridge.SetAttribute ("DeviceName", StringValue ("tap_d_17"));
  tapBridge.Install (adhocNodes.Get (16), adhocDevices.Get (16));
  tapBridge.SetAttribute ("DeviceName", StringValue ("tap_d_18"));
  tapBridge.Install (adhocNodes.Get (17), adhocDevices.Get (17));
  tapBridge.SetAttribute ("DeviceName", StringValue ("tap_d_19"));
  tapBridge.Install (adhocNodes.Get (18), adhocDevices.Get (18));
  tapBridge.SetAttribute ("DeviceName", StringValue ("tap_d_20"));
  tapBridge.Install (adhocNodes.Get (19), adhocDevices.Get (19));
  tapBridge.SetAttribute ("DeviceName", StringValue ("tap_a_21"));
  tapBridge.Install (adhocNodes.Get (20), adhocDevices.Get (20));
  tapBridge.SetAttribute ("DeviceName", StringValue ("tap_a_22"));
  tapBridge.Install (adhocNodes.Get (21), adhocDevices.Get (21));
  tapBridge.SetAttribute ("DeviceName", StringValue ("tap_a_23"));
  tapBridge.Install (adhocNodes.Get (22), adhocDevices.Get (22));
  tapBridge.SetAttribute ("DeviceName", StringValue ("tap_a_24"));
  tapBridge.Install (adhocNodes.Get (23), adhocDevices.Get (23));
  tapBridge.SetAttribute ("DeviceName", StringValue ("tap_a_25"));
  tapBridge.Install (adhocNodes.Get (24), adhocDevices.Get (24));
  



//----------------------------------------------------------------------------------------------------

  Simulator::Stop (Seconds (33.0));
  Simulator::Run ();
  Simulator::Destroy ();

  return 0;
}

