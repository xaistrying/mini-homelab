import subprocess
import json
import os

SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))

TF_DIR = os.path.join(SCRIPT_DIR, "../infrastructure")
GW_DIR = os.path.join(SCRIPT_DIR, "../configuration/setup-gateway-layer")
APP_DIR = os.path.join(SCRIPT_DIR, "../configuration/setup-application-layer")

TPL_FILE = "inventory.ini.tpl"
OUT_FILE = "inventory.ini"

def get_tf_outputs():
    cmd = subprocess.check_output(
        ["terraform", "output", "-json"],
        cwd=TF_DIR
    )
    return json.loads(cmd)

def validate_outputs(data, keys):
    for key in keys:
        if key not in data or not data[key]["value"]:
            raise ValueError(f"Missing terraform output: {key}")

def render_inventory(template_path, variables):
    with open(template_path, "r") as f:
        content = f.read()

    for key, value in variables.items():
        content = content.replace(f"<{key}>", value)

    return content

def write_inventory(dir_path, content):
    output_path = os.path.join(dir_path, OUT_FILE)
    with open(output_path, "w") as f:
        f.write(content)

def main():
    tf_data = get_tf_outputs()

    validate_outputs(tf_data, [
        "gateway_public_ip",
        "app_private_ip"
    ])

    variables = {
        "gateway_public_ip": tf_data["gateway_public_ip"]["value"],
        "app_private_ip": tf_data["app_private_ip"]["value"],
    }

    gw_inventory = render_inventory(
        os.path.join(GW_DIR, TPL_FILE),
        variables
    )

    app_inventory = render_inventory(
        os.path.join(APP_DIR, TPL_FILE),
        variables
    )

    write_inventory(GW_DIR, gw_inventory)
    write_inventory(APP_DIR, app_inventory)

    print("Inventory files generated successfully")


if __name__ == "__main__":
    main()
