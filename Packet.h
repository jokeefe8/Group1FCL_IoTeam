#pragma once
#include <string>
#include <iostream>
using namespace std;

struct Packet {
private:
public:
	string sending_ip;
	string receiving_ip;
	string sending_mac;
	string receiving_mac;
	string sending_port;
	string receiving_port;
	//string sending_port_udp;
	//string receiving_port_udp;
	Packet(string a, string b, string c, string d, string e, string f) :
		sending_ip(a), receiving_ip(b), sending_mac(c), receiving_mac(d), sending_port(e), receiving_port(f) {}
	void print() {
		cout <<
			"Sending IP: " << sending_ip << endl <<
			"Receiving IP: " << receiving_ip << endl <<
			"Sending MAC: " << sending_mac << endl <<
			"Receiving MAC: " << receiving_mac << endl <<
			"Sending Port: " << sending_port << endl <<
			"Receiving Port: " << receiving_port << endl << endl;
	}
};