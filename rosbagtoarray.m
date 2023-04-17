clc
clear
% startの瞬間は110秒から
bag = rosbag('bagfile/2023-03-27-16-30-10.bag');
StartTime = bag.StartTime;

imu = select(bag,'Topic','/dji_osdk_ros/attitude');
imu_data = readMessages(imu);
gps = select(bag,'Topic','/dji_osdk_ros/rtk_position');
gps_data = readMessages(gps);
ouster1 = select(bag,'Topic','/ouster/points');
%%
ouster_data1 = readMessages(ouster1);
gpsstart = cellfun(@(m) m.Header.Stamp.Sec + m.Header.Stamp.Nsec/1000000000.0,gps_data(1));
ousstart = cellfun(@(m) m.Header.Stamp.Sec + m.Header.Stamp.Nsec/1000000000.0,ouster_data1(1));
gpsTime = cellfun(@(m) m.Header.Stamp.Sec + m.Header.Stamp.Nsec/1000000000.0-gpsstart,gps_data);
ousTime = cellfun(@(m) m.Header.Stamp.Sec + m.Header.Stamp.Nsec/1000000000.0-ousstart,ouster_data1);
imuTime = cellfun(@(m) m.Header.Stamp.Sec + m.Header.Stamp.Nsec/1000000000.0-StartTime,imu_data);
%%
% player
xlimits = [-200 200];
ylimits = [-200 200];
zlimits = [-200 200];

% Create a pcplayer object to visualize the lidar scans
lidarPlayer = pcplayer(xlimits,ylimits,zlimits);

% Customize the pcplayer axis labels
xlabel(lidarPlayer.Axes,'X (m)')
ylabel(lidarPlayer.Axes,'Y (m)')
zlabel(lidarPlayer.Axes,'Z (m)')
title(lidarPlayer.Axes,'Lidar Scans')

skipFlame = 5;
for i = 2000:skipFlame:length(ouster_data1)
    ptCloud = pointCloud(readXYZ(ouster_data1{i,1}));
    % Update the lidar display
    view(lidarPlayer,ptCloud)
    pause(0.01)
end