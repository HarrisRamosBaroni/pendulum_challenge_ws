FROM althack/ros2:jazzy-gazebo 

# ** [Optional] Uncomment this section to install additional packages. **

ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update \
   && apt-get -y install --no-install-recommends fzf fd-find \
   #
   # Clean up
   && apt-get autoremove -y \
   && apt-get clean -y \
   && rm -rf /var/lib/apt/lists/*
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