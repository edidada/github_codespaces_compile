# ROS 2 Jazzy — Linux / jazzy

This branch builds the supported ROS 2 Jazzy LTS source set up through
`rclcpp`, the C++ client-library core.  It imports the upstream `ros2.repos`
manifest, resolves dependencies with `rosdep`, and compiles with `colcon`.

The scope intentionally excludes device-specific demos and physical-robot
integration, which are not meaningful on a GitHub-hosted runner.  Building
through `rclcpp` validates the core C/C++ middleware, interfaces, code
generation and C++ API stack from official ROS 2 sources.

Source: <https://github.com/ros2/ros2>
