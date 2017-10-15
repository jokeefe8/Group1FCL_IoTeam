#pragma once
#include "Packet.h"
#include <vector>
#include <fstream>
#include <sstream>

// magic number central
#define NUMBER_OF_COLUMNS 8 // number of columns in input file
#define LIGHT_PORT "9999"
#define ARLO_PORT "1900" // "Universal Plug 'N Play"
#define ECHO_PORT1 "60290" // what is this
#define ECHO_PORT2 "443" // HTTPS




using namespace std;

bool is_local_ip(string ip) { // sneaky workaround
	if (ip != "") {
		string prefix = ip.substr(0, 3);
		return prefix == "10." || prefix == "192";
	}
	else return false;
}

void read(string filename, vector<Packet>& packet_vector) {
	ifstream input(filename);
	//input.open(filename);

	vector<string> packet_args(NUMBER_OF_COLUMNS);

	if (input.is_open()) {
		string line;
		while (getline(input, line)) {
			stringstream line_stream(line);
			string value;
			for (int i = 0; i < NUMBER_OF_COLUMNS; i++) {
				getline(line_stream, value, ',');
				packet_args[i] = value;
			}
			bool add = true; // Boolean determines if this is a unique device sending packet
			for (auto i : packet_vector) {
				if (packet_args[0] == i.sending_ip &&
					(packet_args[4] == i.sending_port || packet_args[6] == i.sending_port)) {
					add = false;
				}
			}
			// construct a new Packet obj and add to vector if it is a useful packet
			if (add && is_local_ip(packet_args[0]) && packet_args[4] != "") {
				packet_vector.push_back(Packet(
					packet_args[0],
					packet_args[1],
					packet_args[2],
					packet_args[3],
					packet_args[4],
					packet_args[5]
				));
			}
			else if (add && is_local_ip(packet_args[0]) && packet_args[6] != "") {
				packet_vector.push_back(Packet(
					packet_args[0],
					packet_args[1],
					packet_args[2],
					packet_args[3],
					packet_args[6],
					packet_args[7]
				));
			}
		}
	}
	input.close();
}

bool is_Light(const Packet& p) { return p.sending_port == LIGHT_PORT || p.receiving_port == LIGHT_PORT; }
bool is_Arlo(const Packet& p) { return /*p.sending_port == ARLO_PORT ||*/ p.receiving_port == ARLO_PORT; }
bool is_Echo(const Packet& p) { return p.sending_port == ECHO_PORT1 || p.receiving_port == ECHO_PORT1 ||
								p.sending_port == ECHO_PORT2 || p.receiving_port == ECHO_PORT2; }

void update_info(Device& d, const Packet& p) {
	if (d.mac_address == p.sending_mac) {
		if (is_Light(p)) { d.device_type = "Smart Light"; d.comm_method = "802.11 - Wi-Fi"; }
		else if (is_Arlo(p)) { d.device_type = "Arlo Camera"; d.comm_method = "802.11 - Wi-Fi"; }
		else if (is_Echo(p)) { d.device_type = "Amazon Echo"; d.comm_method = "802.11 - Wi-Fi"; }
	}
}