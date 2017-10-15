#include "Packet.h"
#include <vector>
#include <fstream>
#include <sstream>

using namespace std;

vector<Packet>& read(string& filename) {
	vector<Packet> packet_vector;
	ifstream input(filename);
	string line;
	//input.open(filename);

	int no_of_col = 6; // number of columns in the .txt input file
	vector<string> packet_args(no_of_col);

	if (input.is_open()) {
		while (getline(input, line)) {
			stringstream line_stream(line);
			string cell;
			for (int i = 0; i < no_of_col; i++) {
				getline(line_stream, cell, ',');
				packet_args[i] = cell;
			}
			packet_vector.push_back(Packet(
				packet_args[0],
				packet_args[1],
				packet_args[2],
				packet_args[3],
				packet_args[4],
				packet_args[5]
			));  // man this code is garbage
		}
	}
	input.close();
	return packet_vector;
}