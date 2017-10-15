#pragma once
#include "Packet.h"
#include <string>
#include <list>

using namespace std;

struct Device {
private:
public:
	string ip_address = "unknown";
	string mac_address = "unknown";
	string device_type = "unknown";
	string comm_method = "802.11 - Wi-Fi";
	Device(Packet& p) { // assume that the Packet input is sent BY the device
		ip_address = p.sending_ip;
		mac_address = p.sending_mac;
	}
	void print() {
		cout << "Device Type: " << device_type << endl <<
			"IP Address: " << ip_address << endl <<
			"MAC Address: " << mac_address << endl << 
			"Protocol used: " << comm_method << endl << endl;
	}
};
