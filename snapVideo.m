%% Using the Kinect(R) for Windows(R) from Image Acquisition Toolbox(TM)
% This example shows how to obtain the data available from the Kinect for
% Windows sensor using Image Acquisition Toolbox:
%
% Copyright 2012-2014 The MathWorks, Inc.


%% Add Utility Function to the MATLAB Path
% In order the keep this example as simple as possible, some utility functions 
% for working with the Kinect for Windows metadata have been created.  These 
% functions are not on the MATLAB path by default.  In order to use them, 
% the directory containing the utility functions must be added to the MATLAB path.
% This path includes the skeletalViewer function which accepts the skeleton data, 
% color image and number of skeletons as inputs and displays the skeleton 
% overlaid on the color image 
utilpath = fullfile(matlabroot, 'toolbox', 'imaq', 'imaqdemos', ...
    'html', 'KinectForWindows');
addpath(utilpath);


%% See What Kinect for Windows Devices and Formats are Available
% The Kinect for Windows has two sensors, an color sensor and a depth
% sensor. To enable independent acquisition from each of these devices,
% they are treated as two independent devices in the Image
% Acquisition Toolbox. This means that separate VIDEOINPUT object needs to be created
% for each of the color and depth(IR) devices.

% The Kinect for Windows Sensor shows up as two separate devices in IMAQHWINFO. 
hwInfo = imaqhwinfo('kinect')


%%
hwInfo.DeviceInfo(1)

%% 
hwInfo.DeviceInfo(2)

%% Acquire Color and Depth Data
% In order to acquire synchronized color and depth data, we must use
% manual triggering instead of immediate triggering. The default immediate
% triggering suffers from a lag between streams while performing synchronized
% acquisition. This is due to the overhead in starting of streams sequentially.

% Create the VIDEOINPUT objects for the two streams
colorVid = videoinput('kinect',1)
%%
depthVid = videoinput('kinect',2)

%%
% 

% Set the triggering mode to 'manual'
triggerconfig([colorVid depthVid],'manual');

%%
%
% Set the FramesPerTrigger property of the VIDEOINPUT objects to '100' to
% acquire 100 frames per trigger. In this example 100 frames are acquired to
% give the Kinect for Windows sensor sufficient time to start tracking a
% skeleton.
colorVid.FramesPerTrigger = 10;
depthVid.FramesPerTrigger = 10;

%%
%

% Start the color and depth device. This begins acquisition, but does not
% start logging of acquired data.
start([colorVid depthVid]);
%%
%

% Trigger the devices to start logging of data.
trigger([colorVid depthVid]);
%%
%

% Retrieve the acquired data
[colorFrameData, colorTimeData, colorMetaData] = getdata(colorVid);
[depthFrameData, depthTimeData, depthMetaData] = getdata(depthVid);
%%
%

% Stop the devices
stop([colorVid depthVid]);
