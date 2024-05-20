import sys
import re
import json

def convert_to_json(input_file, input_file_2, output_file, mode):
    # Read the input file
    with open(input_file, 'r') as file:
        data = file.read()

    with open(input_file_2, 'r') as file:
        cfg = json.load(file)

    pub_ip = cfg['public_ip']['value']

    # Split the data into blocks based on the interface
    blocks = re.split(r'\n\s*\n', data)

    # Initialize a dictionary to hold the JSON data
    json_data = {}

    # Process each block
    for block in blocks:
        lines = block.strip().split('\n')
        interface_name = lines[0].split(': ')[1].strip()
        interface_data = {}
        for line in lines[1:]:
            key, value = line.split(': ')
            interface_data[key.strip()] = value.strip()
        json_data[interface_name] = interface_data

    # Output the JSON data to the output file
    #with open(output_file, 'w') as json_file:
    #    json.dump(json_data, json_file, indent=2)

    cmd = f"sudo wg set wg0 peer {json_data['wg0']['public key']} allowed-ips {cfg['wg0']}/32 endpoint {cfg['public_ip']['value']}:{json_data['wg0']['listening port']}\n"

    with open(output_file, mode) as f:
        f.write(cmd)

    print(f"Commands are saved to '{output_file}'")

# Check if the correct number of command-line arguments is provided
if len(sys.argv) != 5:
    print("Usage: python script.py input_file_path input_file_path_2 output_file_path write_mode")
else:
    # Get the input and output file paths from command-line arguments
    input_file_path = sys.argv[1]
    input_file_path_2 = sys.argv[2]
    output_file_path = sys.argv[3]
    mode = sys.argv[4]

    # Call the conversion function with the provided file paths
    convert_to_json(input_file_path, input_file_path_2, output_file_path, mode)

