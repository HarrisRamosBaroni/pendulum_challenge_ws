FROM althack/ros2:jazzy-gazebo 

# ** [Optional] Uncomment this section to install additional packages. **

ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update \
   && apt-get -y install --no-install-recommends \
      python3-scipy python3-numpy \
      build-essential liblapack-dev libopenblas-dev python3-dev python3-venv \
      fzf fd-find \
      ros-jazzy-ros2-control \
      ros-jazzy-ros2-controllers \
      ros-jazzy-gz-ros2-control \
   # Clean up
   && apt-get autoremove -y \
   && apt-get clean -y \
   && rm -rf /var/lib/apt/lists/*

# Create virtual environment
COPY requirements.txt .
RUN python3 -m venv /opt/venv \
   && /opt/venv/bin/pip install --upgrade pip \
#    && /opt/venv/bin/pip install slycot control
   && /opt/venv/bin/pip install -r requirements.txt

# Make venv accessible to ROS
ENV PATH="/opt/venv/bin:${PATH}"
ENV PYTHONPATH="/opt/venv/lib/python3.12/site-packages:${PYTHONPATH}"

ENV DEBIAN_FRONTEND=dialog

# Set up auto-source of workspace for ros user
ARG WORKSPACE
RUN echo "if [ -f ${WORKSPACE}/install/setup.bash ]; then source ${WORKSPACE}/install/setup.bash; fi" >> /home/ros/.bashrc

# Set up a directory for runtime files dump which is writable by the ros user
RUN echo "export XDG_RUNTIME_DIR=/tmp/runtime-ros" >> /home/ros/.bashrc && \
    echo "mkdir -p \$XDG_RUNTIME_DIR" >> /home/ros/.bashrc && \
    echo "chmod 700 \$XDG_RUNTIME_DIR" >> /home/ros/.bashrc

# Add fuzzy finder commands for easier navigation
# Default depth is 3 if no argument is provided 
RUN echo "alias fcd='cd \$(fdfind --type d --follow --hidden --exclude .git | fzf)'" >> /home/ros/.bashrc
RUN echo "fcds() { \
    local depth=${1:-3}; \
    cd \"$(fdfind --type d --follow --hidden --exclude .git -d \"$depth\" | fzf)\"; \
}" >> /home/ros/.bashrc