# ROS2 Jazzy Cart Pendulum robot simulation and control using Gazebo Sim Harmonic and ROS2 Control

## Included packages

The relevant ros2 packages are all found in `src/inverted_pendulum/`

* `inverted_pendulum_description` - holds the sdf and urdf description of the simulated system and any other assets.

* `inverted_pendulum_gazebo` - holds gazebo specific code and configurations.

* `inverted_pendulum_controller` - holds a ros2 python node publishing force commands to a ros2 controller.

* `inverted_pendulum_bringup` - holds launch files and high level utilities.

## How to run the simulation
Follow the steps in the "How to work on this repo" section of this readme file up to and completing the "Setup and development workflow" steps, except don't do any development.
Run `ros2 launch inverted_pendulum_bringup inverted_pendulum.launch.py` to launch the main ros2 nodes and gazebo simulation. Connect on localhost:6080 if using noVNC for GUI.
Close gazebo sim and send a `control+c` command to stop all nodes gracefully and wait 30 seconds for everything to clean up before starting another simulation or you might find that multiple occurrences of controller managers and gz_ros_control nodes spawn.

## The overall system explanation
### Elements and some connections
In `inverted_pendulum_description`, the `models/inverted_pendulum/urdf/model.urdf` robot model is defined. It uses a plugin called `gz_ros2_control-system`. This starts a ros2 control 'controller manager'. The code block calling the plugin references a configuration file for the controller manager. The original code for this configuration file can be found in `inverted_pendulum_controller/config/`. It is sourced also in some launch files, which look for share directories of packages, so the `config` subdirectory is installed into the share directory of `inverted_pendulum_controller` as specified in its `setup.py`.

We can also find some basic world description files in `inverted_pendulum_gazebo` package in the `worlds` subdirectory.

The `inverted_pendulum.launch.py` script in `inverted_pendulum_bringup/launch` package is responsible for 
1. starting gazebo sim...
2. ... which itself starts the controller manager since we reference the required plugin `gz_ros2_control-system`,
3. loading a world sdf file into gazebo sim,
4. spawning the the robot urdf in the world,
5. starting a `robot_state_publisher`,
6. starting the robot controller python node in `inverted_pendulum_controller` package,
7. starting spawners for the ros2 control controllers
8. starting a bridge node which manages conversion between ros2 and gazebo sim messages by bridging topics
9. optionally starting a node to start the rviz GUI.

The `robot_state_publisher` publishes robot state data to `/robot_description` ros2 topic. The controller manager references data on this `/robot_description` topic to start up the controllers as specified in the `inverted_pendulum_controller/config/cart_controllers.yaml` config file.

### Summary of the Data Flow
1. `inverted_pendulum.urdf` loaded in gazebo sim
2. Gazebo sim publishes joint states on `/world/demo/model/inverted_pendulum/joint_state` topic.
3. `inverted_pendulum_bridge.yaml` file converts this gazebo data to ROS data on the `/joint_states` topic.
4. `inverted_pendulum_controller.py` node subscribes to `joint_states` topic and publishes a force commands directly to `/cart_effort_controller/commands` topic.
5. ros2 control controller named `cart_effort_controller`  (configured in `cart_controllers.yaml`) receives the force command.
6. `inverted_pendulum.urdf` (with the gazebo_ros2_control plugin) uses the force command to call physics engine routines (like SetForce) on the cart_joint.
7. Gazebo’s physics engine updates the simulation, closing the loop from steps 2 to 7.

## How to work on this repo
See [this template to set up VSCode for ros2 development with dev containers.](https://github.com/athackst/vscode_ros2_workspace/tree/jazzy).

### Clone this repo

Clone this repo.

### Get the right devcontainer.json

Get the right `devcontainer.json` configuration file for the Dev Containers extension to source when building your docker image and running a container from that image.
Place it in `.devcontainers`, at the same level as `Dockerfile`.
TODO: link to the two appropriate and tested `devcontainer.json` files.

### Open repo in vscode

Open the repo in VSCode (File->Open Folder).
Search in the command palette "Remote Containers: Reopen in container" and select.
![template_vscode_bottom](https://user-images.githubusercontent.com/6098197/91332638-5d47b780-e781-11ea-9fb6-4d134dbfc464.png)

VSCode will build the dockerfile inside of `.devcontainer` for you.  If you open a terminal inside VSCode (Terminal->New Terminal), you should see that your username has been changed to `ros`, and the bottom left green corner should say "Dev Container"

![template_container](https://user-images.githubusercontent.com/6098197/91332895-adbf1500-e781-11ea-8afc-7a22a5340d4a.png)

### Setup and development workflow

1. Run `./gzsetup.sh` from root of workspace. The setup commands for the code: installs dependencies.
2. Run `export GZ_VERSION=harmonic` from any directory.
3. Run `./gzbuild.sh` from root of workspace. The build commands for the ros2 packages in src/inverted_pendulum. Does a `--merge-install` and `--symlink-install`.
4. Run `source install/setup.bash` to get access to the compiled packages in step 3.
5. Develop.
6. Repeat step 3 and 4 when making changes to packages which require recompiling.

### Debugging

This template sets up debugging for python files, gdb for cpp programs and ROS launch files.  See [`.vscode/launch.json`](.vscode/launch.json) for configuration details.

### Access container from a different terminal emulator to the vscode integrated one
1. May need to run `xhost +local:` in your chosen terminal emulator. "Purpose: It modifies the access control list of the X server to permit connections from any local user (users logged into the same machine) via local sockets." - llm
2. Run `docker ps` and find the name of the container generated by vscode. Let us say the name is `happy_elephant`.
3. Run `docker exec -it -u ros happy_elephant /bin/bash` to open an interactive subshell running a bash session in the `happy_elephant` container as the `ros` user.
4. Run `exit` to end the subshell session.

## FAQ

### WSL2

#### The gui doesn't show up

This is likely because the DISPLAY environment variable is not getting set properly.

1. Find out what your DISPLAY variable should be

      In your WSL2 Ubuntu instance

      ```
      echo $DISPLAY
      ```

2. Copy that value into the `.devcontainer/devcontainer.json` file

      ```jsonc
      	"containerEnv": {
		      "DISPLAY": ":0",
         }
      ```

#### I want to use vGPU

If you want to access the vGPU through WSL2, you'll need to add additional components to the `.devcontainer/devcontainer.json` file in accordance to [these directions](https://github.com/microsoft/wslg/blob/main/samples/container/Containers.md)

```jsonc
	"runArgs": [
		"--network=host",
		"--cap-add=SYS_PTRACE",
		"--security-opt=seccomp:unconfined",
		"--security-opt=apparmor:unconfined",
		"--volume=/tmp/.X11-unix:/tmp/.X11-unix",
		"--volume=/mnt/wslg:/mnt/wslg",
		"--volume=/usr/lib/wsl:/usr/lib/wsl",
		"--device=/dev/dxg",
      		"--gpus=all"
	],
	"containerEnv": {
		"DISPLAY": "${localEnv:DISPLAY}", // Needed for GUI try ":0" for windows
		"WAYLAND_DISPLAY": "${localEnv:WAYLAND_DISPLAY}",
		"XDG_RUNTIME_DIR": "${localEnv:XDG_RUNTIME_DIR}",
		"PULSE_SERVER": "${localEnv:PULSE_SERVER}",
		"LD_LIBRARY_PATH": "/usr/lib/wsl/lib",
		"LIBGL_ALWAYS_SOFTWARE": "1" // Needed for software rendering of opengl
	},
```