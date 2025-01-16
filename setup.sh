#!/bin/bash
set -e

vcs import < src/ros2.repos src
sudo apt-get update
rosdep update --rosdistro=$ROS_DISTRO  # 'rosdep init' command is run in the base the dockerfile althack/ros2:jazzy-gazebo
rosdep install --from-paths src --ignore-src -y --rosdistro=$ROS_DISTRO
