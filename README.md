# Waste-Free Home

## Overview

**Waste-Free Home** is an IoT system designed to create a "green" home with various environmentally friendly devices. The project integrates multiple components, including an MQTT broker, two FastAPI servers, and a Flutter app, to provide a comprehensive solution for managing and monitoring different types of devices in a sustainable home environment.

## Features

- **Device Management**: Track and manage a variety of "green" home devices.
- **Data Recording**: Collect and visualize data from different sensors and devices.
- **Service Discovery**: Use mDNS for discovering and configuring services within the system.
- **Real-Time Updates**: Receive real-time updates from devices via WebSocket.
- **Cross-Platform**: Includes a mobile app developed with Flutter for Android and potentially other platforms.

## Components

### 1. Local Hub (Home Server)
- **MQTT Broker (Mosquitto)**: Handles MQTT messages exchanged between devices and the local FastAPI server.
- **FastAPI HTTP Server**: Manages local devices and their interactions.
  - **Data Aggregation**: Collects data from all devices in the home and sends this data to the remote FastAPI server for storage and remote access.
- **mDNS Service Broadcasting**: The local hub broadcasts its presence and service information using mDNS. This allows the Flutter app and Arduino projects to discover and connect to it.

### 2. Remote Server
- **FastAPI Server**: Handles data storage and remote access.
  - **Data Storage**: Receives and stores data collected from the local hubs.
  - **WebSocket Management**: Handles WebSocket connections for real-time updates and communications.
  - **JWT Authentication**: Secures API endpoints with JWT tokens.
  - **API Endpoints**: Provides endpoints for retrieving and managing stored data.
  - **User and Device Manipulation**: Manages user accounts and device configurations.
  - **File Handling**: Serves device thumbnail images through `FileResponse`.

### 3. Flutter App
- **WasteFreeHome App**: A mobile application to interact with and control the IoT system.
  - **Dio Client**: Configured for API requests and token management.
  - **UI Components**: Features screens for device details, data visualization, and control.
  - **mDNS Service Discovery**: Configured to discover the local hub service automatically and connect to the HTTP Server.

### 4. Arduino Projects
- **Devices**: Sensors and actuators located within the home.
- **Sensors**: Includes code for interfacing with various sensors and devices.
- **mDNS Service Discovery**: Configured to discover the local hub service automatically and connect to the MQTT broker.

## Getting Started

### Prerequisites

- **Docker**: Required for running the PostgreSQL, TimeScale, Mosquitto, and FastAPI servers.
- **Flutter**: For developing and running the mobile app.
- **Arduino IDE**: For ESP32 and ESP8266 development.

### Installation

1. **Clone the Repository**
   ```bash
   git clone https://github.com/jokicjovan/Waste-Free-Home.git
   cd Waste-Free-Home

2. **Setup Docker Containers** (optional)
    - Make sure Docker and Docker Compose are installed.
    - Start the containers with:
        ```bash
        docker-compose up

    - **Note**: Currently, FastAPI servers are not set up to work in Docker, so do steps 4. and 5. from the next section (Running Individual Services).

3. **ESP32/ESP8266**
    - Open the Arduino IDE.
    - Load and upload the respective .ino files to your ESP32/ESP8266 modules.

4. **Flutter App**
    - Navigate to the Flutter app directory
    - Install dependencies and run the app:
        ```bash
        flutter pub get
        flutter rune

### Running Individual Services (If Not Using Docker)
1. **PostgreSQL**
   - Install PostgreSQL from [PostgreSQL's official site](https://www.postgresql.org/download/).
   - Start PostgreSQL service:
     ```bash
     sudo service postgresql start
     ```

2. **TimescaleDB**
   - Install TimescaleDB from [TimescaleDB's official site](https://www.timescale.com/products/timescaledb/install).
   - Start TimescaleDB service (usually integrated with PostgreSQL):
     ```bash
     sudo service postgresql start
     ```

3. **Mosquitto**
   - Install Mosquitto from [Mosquitto's official site](https://mosquitto.org/download/).
   - Start Mosquitto service:
     ```bash
     sudo service mosquitto start
     ```
   - Check Mosquitto status:
     ```bash
     sudo service mosquitto status
     ```
   - Configure Mosquitto if needed, by editing the configuration file usually found at `/etc/mosquitto/mosquitto.conf`.

4. **Local Hub Server**
   - Navigate to the FastAPI server directory for the local hub:
     ```bash
     cd path/to/local/hub/server
     ```
   - Install dependencies:
     ```bash
     pip install -r requirements.txt
     ```
   - Start the server:
     ```bash
     uvicorn main:app --host 0.0.0.0 --port 8000
     ```
   - Adjust the port if necessary to avoid conflicts with other services.

5. **Remote Server**
   - Navigate to the FastAPI server directory for the remote server:
     ```bash
     cd path/to/remote/server
     ```
   - Install dependencies:
     ```bash
     pip install -r requirements.txt
     ```
   - Start the server:
     ```bash
     uvicorn main:app --host 0.0.0.0 --port 9000
     ```
   - Adjust the port if necessary to avoid conflicts with other services.


## Configuration

### Local Hub Server
- **.env File**: Configure the following settings in the `.env` file for the Local Hub Server. The `.env` file should be located in the root directory of the Hub project:
  - **Hub**:
    ```env
    hub_id=hub_uuid
    hub_hostname=hub_hostname
    ```
  - **Its HTTP server information**
    ```env
    http_port=http_port
    ```
  - **MQTT Broker Configuration**:
    ```env
    mqtt_broker_port=mqtt_broker_port
    mqtt_username=mqtt_username
    mqtt_password=mqtt_password
    ```
  - **Remote Server information**:
    ```env
    server_hostname=server_hostname
    server_port=server_port
    user_email=user_email
    user_password=user_password
    ```
  - **Optional**:
    ```env
    device_record_topic=device/+/record
    device_state_topic=device/+/state
    server_devices_endpoint=API/devices
    server_records_endpoint=API/records
    server_auth_endpoint=API/auth
    jwt=jwt
    ```


### Remote Server
- **.env File**: Configure the following settings in the `.env` file for the Remote Server. The `.env` file should be located in the root directory of the Server project:
  - **PostgreSQL Configuration**:
    ```env
    postgres_user=postgres_user
    postgres_password=postgres_password
    postgres_hostname=postgres_hostname
    postgres_port=postgres_port
    postgres_name=postgres_name
    ```
  - **TimescaleDB Configuration**:
    ```env
    timescale_user=timescale_user
    timescale_password=timescale_password
    timescale_hostname=timescale_hostname
    timescale_port=timescale_port
    timescale_name=timescale_name
    ```
  - **Optional**:
    ```env
    secret_key=secret_key
    algorithm=HS256
    access_token_expire_minutes=1440
    devices_thumbnails_path=static/devices/thumbnails/
    ```


### Flutter App
- **.env File**: Configure the following settings in the `.env` file for the Flutter application, located in the `assets` folder at the Client project root:
  - **Mandatory:**
    ```env
    server_hostname=server_hostname
    server_port=server_port
    ```
  - **Optional**
    ```env
    server_auth_endpoint=/API/auth
    server_devices_endpoint=/API/devices
    server_records_endpoint=/API/records
    ```

### Mosquitto Configuration

#### `passwd` File
- **Location**: Typically located at `/etc/mosquitto/passwd`.
- **Purpose**: Stores user credentials for Mosquitto.
- **Format**: Contains hashed passwords for MQTT users, created using the `mosquitto_passwd` command.
- **Note**: Ensure the `passwd` file is properly secured and accessible only by the Mosquitto service.

#### `mosquitto.conf` File
- **Location**: Typically found at `/etc/mosquitto/mosquitto.conf`.
- **Configuration**:
  - **Listener Ports**: Specify the port for MQTT connections.
    ```conf
    listener 1883
    ```
  - **Authentication and Authorization**: Define the path to the password file for user authentication.
    ```conf
    password_file /etc/mosquitto/passwd
    allow_anonymous false
    ```
  - **Protocol**: Set the MQTT protocol.
    ```conf
    protocol mqtt
    ```

### Arduino Configurations 
- **Note**: The `config.h` files should be located in the same directory as their respective `.ino` files for proper configuration.
- **config.h in WasteSorter**
  ```cpp
  #ifndef CONFIG_H
  #define CONFIG_H

  // Device
  const char* device_id = "device_uuid"
  
  // MQTT
  const char* mqtt_username = "mqtt_username";
  const char* mqtt_password = "mqtt_password";

  // Network
  const char* ssid = "ssid";
  const char* password = "password";

  #endif
  ```

- **config.h in ThermoHumidMeter**
    ```cpp
    #ifndef CONFIG_H
    #define CONFIG_H

    // Device
    const char* device_id = "device_uuid";
    
    // MQTT
    const char* mqtt_username = "mqtt_username";
    const char* mqtt_password = "mqtt_password";

    // Network
    const char* ssid = "ssid";
    const char* password = "password";

    #endif
    ```

**Ensure all configuration files are correctly set up and secured to ensure proper operation of your IoT system.**


## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- **FastAPI**: For building the servers with modern, high-performance Python.
- **Mosquitto**: For the MQTT broker solution.
- **Flutter**: For the cross-platform mobile app development framework.
- **Arduino**: For the development environment used with ESP32 and ESP8266.
