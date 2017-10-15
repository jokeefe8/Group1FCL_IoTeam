#include "Device.h"
#include "functions.h"

using namespace std;

int main(int argc, char* argv[]) {
	string current_program = argv[0];
	string filename;
	vector<string> all_args;

	// assuming that an input is provided or uncaught exception...
	filename = argv[1];
	all_args.assign(argv + 1, argv + argc);

	vector<Packet> packets;
	vector<Device> devices;
	read(filename, packets);

	bool add;
	vector<string> seen_macs(1);
	for (auto i : packets) { // every packet saved
		add = true;
		for (auto j : seen_macs) { // every seen MAC
			if (i.sending_mac == j) add = false;
			for (int k = 0; k < devices.size(); update_info(devices[k++], i));
		}
		if (add) {
			Device new_device2 = Device(i);
			update_info(new_device2, i);
			devices.push_back(new_device2);
			seen_macs.push_back(i.sending_mac);
		}
	}
	for (auto i : devices) i.print();
	//system("pause");
	return 0;
}