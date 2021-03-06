
# pySoRo  

This software is for creating data of moving soft robots. The  
software uses multiple intel real sensors to capture the current  
state of a soft robot.  

## Intel Real Sense  

In this project we use the librealsense python API. One can clone a git repository from here  

https://github.com/IntelRealSense/librealsense  

We did encounter a few mac-specific challenges when working with this library.  

### Third party libusb library  

In the CMake settings a library named usb is added with the TARGET_LINK_LIBRARIES() command. This name refers to the libusb-library that is bundled with librealsense and not the system libusb library. Unfortunately, CMake generates makefiles using the name usb and that will cause the makefile to link against the system installed library libsub. The solution we used is to rename the local bundled library to XXusb. Here are the details of how we did that. In the file librealsense/CMakeLists.txt  

```
if(NOT WIN32)  
  target_link_libraries(realsense2 PRIVATE XXusb)  
elseif(FORCE_LIBUVC)  
  target_link_libraries(realsense2 PRIVATE XXusb)  
endif()  
```

Next in the file librealsense/third-party/libsub/CMakeLists.txt we changed names as well.  

```
project(XXusb)  

add_library(XXusb STATIC ${LIBUSB_C} ${LIBUSB_H})  

if(WIN32)  
  set_target_properties (XXusb PROPERTIES FOLDER "3rd Party")  
endif()  

if(APPLE)  
  find_library(corefoundation_lib CoreFoundation)  
  find_library(iokit_lib IOKit)  
  TARGET_LINK_LIBRARIES(XXusb objc ${corefoundation_lib} ${iokit_lib})  
endif()  
```

### Installing pyrealsense2  
We mostly followed the description from the library  

https://github.com/IntelRealSense/librealsense/blob/master/doc/installation_osx.md  

There are some slight changes to this description. We used Macport instead of brew. Hence, we wrote  


```
sudo port install libusb  
sudo port install pkgconfig  
sudo port install glfw  
```


In CMake one has to remember to turn on BUILD_PYTHON_BINDINGS to get the python wrapper installed later on. Once  
CMake have generated your xcode project files build the install  
target from the command line as sudo user. It all looks like this.  


```
mkdir build  
cd build  
cmake .. -DBUILD_PYTHON_BINDINGS=true -DBUILD_EXAMPLES=true -DBUILD_WITH_OPENMP=false -DHWM_OVER_XU=false -G Xcode  
sudo xcodebuild -target install  
```


The install target will copy the final library files into the usr/local/lib folder for you. To make sure your python installation can find the new library you  
might want to make some changes to your .profile file by adding  


```
export PYTHONPATH=$PYTHONPATH:/usr/local/lib  
```

### Installing pyrealsense2  on Windows 10

#### software requirements
Microsoft Visual Studio 2015 or later

CMake v3.8+ (https://cmake.org/download/)

Python 3.5 or later

Anaconda (preferably)

#### Process:
You should edit all paths in istructions for your own.

1) Run CMake Gui "cmake-gui.exe".
2) On "Where is the source code:", click "Browse Source" button and configure the path on librealsense, for example "C:/Users/PCName/Desktop/librealsense".
3) Create "build" folder on librealsense path folder. On "Where to build the binaries:", click button "Browse Build" button and configure the path as for example "C:/Users/PCName/Desktop/librealsense/build". 
4) Make sure that you check on "Grouped" and "Advanced" checkbox for easy to identify each node and variables.
5) Then click "Configure" button.
6) On "Specify the generator for this project", select you visual studio version, as for example "Visual Studio 14 2015 Win64"
7) Then click "Finish" button.
8) After configuring done, on "BUILD" node, check "BUILD_PYTHON_BINDINGS" checkbox button.
9) Then click "Configure" button again.
10) On "Ungrouped Entries", identify variable "PYTHON_EXECUTABLE", change the path to anaconda python.exe in your virtual environment path as for example "C:/Users/PCName/Anaconda3/envs//python.exe" or "C:/Users/abcd/AppData/Local/Continuum/anaconda3/envs//python.exe" 
11) Then click "Generate" button, after all configuring and generating successfully done, click "Open Project".
12) After Visual Studio IDE open, then start compiling/debug the solution.

After compiling python folder finish, you should see output files under "librealsense/build/Debug folder as attachment inside the build, few things to do as below :

13) change the name of "pybackend2.cp36-win_amd64.pyd" to "pybackend2.pyd" and "pyrealsense2.cp36-win_amd64.pyd" to "pyrealsense2.pyd"
There are 2 methods on copying the

13.1.a) copy "pybackend2.pyd", "pyrealsense2.pyd" and "realsense2.dll" to "DLLs" folder. For example "C:/Users/abcd/AppData/Local/Continuum/anaconda3/envs//DLLs"

13.1.b) copy "realsense2.lib" to "libs" folder. For example "C:/Users/abcd/AppData/Local/Continuum/anaconda3/envs//libs"

OR

13.2.a) You can also copy the files ("pyrealsense.2pyd" and "realsense2.dll" files) to the folder "site-packages" as for example : "C:\Users\PCName\Anaconda3\envs\EnvironmentName\Lib\site-packages".

In order to test create new .py file, type followed strings and run it:
```
import pyrealsense2 as rs
```

### Adding Two Dimensional Data Protocols  
We ran profiling tools on current implementation and found that close to 80% of the application time is spend on converting buffer data from librealsense into numpy arrays that are more appropriate for openGL vertex buffers.  

Here is the code that is causing the bad performance  


```
def update(self, coordinates, uvs):  
  vertex_data = []  
  index_data = []  
  index = 0  
  for i in range(len(coordinates)):  
    if fabs(coordinates[i][2]) > 0.0:  
      vertex_data.append(coordinates[i][0])  
      vertex_data.append(coordinates[i][1])  
      vertex_data.append(coordinates[i][2])  
      vertex_data.append(uvs[i][0])  
      vertex_data.append(uvs[i][1])  
      index_data.append(index)  
      index += 1  
  vertex_array = np.array(vertex_data, dtype=np.float32)  
  index_array = np.array(index_data, dtype=np.uint32)  
  self.count = index  

  glBindBuffer(GL_ARRAY_BUFFER, self.vbo)  
  glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, self.ibo)  
  glBufferSubData(GL_ARRAY_BUFFER, 0, vertex_array.nbytes, vertex_array)  
  glBufferSubData(GL_ELEMENT_ARRAY_BUFFER, 0, index_array.nbytes, index_array)  
```

It is not really the openGL call at the end that is the problem, but rather that we setup up a for-loop that incrementally creates two lists in order to zip two numpy arrays into one numpy array. This is slow. Ideally we would much rather write something Like  


```
vertex_array = np.hstack((coordinates, uvs))  
index_array = np.arrange(len(vertex_array))  
```

Unfortunately, the current BufData implementation in the python wrapper of librealsense does not give us numpy arrays coordinates and uvs that have the right shape for writing the code above. With the current implementation when one writes the python code  

```
coordinates = np.asanyarray(points.get_vertices())  

print(type(coordinates[0]))  
print(coordinates.dtype)  
print(coordinates.shape)  
```

Then we get the output such as this  


> <class 'numpy.void'>   [('f0', '<f4'), ('f1', '<f4'), ('f2', '<f4')]  
> (307200,)


This is a little unexpected. We would much rather have the output:  


> <class 'numpy.ndarray'>   float32   (307200, 3)


This is much more convenient data type to work with in Python. Hence, we made a few changes. In the python binders wrappers/python.cpp in the class BufData we added the constructor  

```
BufData( void *ptr       // Raw pointer  
, size_t count  // Number of points  
, size_t dim    // The number of floats inside a point  
)  : BufData(  ptr  
, sizeof(float)  
, "@f"  
, 2  
, std::vector<size_t> { count, dim }  
, std::vector<size_t> { sizeof(float)*dim, sizeof(float) }  
)  { }  
```


Finally we extended the get_vertices and get_texture_coordinates  
wrappers in the points class to create 2-dimensional buffers  
instead. Like this  

```
py::class_<rs2::points, rs2::frame> points(m, "points");  
points.def(py::init<>())  
.def(py::init<rs2::frame>())  
.def("get_vertices_EXT", [](rs2::points& self) -> BufData  
{  
return BufData(  
const_cast<rs2::vertex*>(self.get_vertices())  //Raw pointer  
, self.size()           // Number of vertices  
, 3                     // A vertex got 3 coordinates  
);  

}, py::keep_alive<0, 1>())  
.def("get_texture_coordinates_EXT", [](rs2::points& self) -> BufData  
{  
return BufData(  
const_cast<rs2::texture_coordinate*>(self.get_texture_coordinates())  //Raw pointer  
, self.size()           // Number of texture coordinates  
, 2                     // A texture coordinate got 2 coordinates  
);  
}, py::keep_alive<0, 1>())  
.def("get_vertices", [](rs2::points& self) -> BufData  
{  
return BufData(  
const_cast<rs2::vertex*>(self.get_vertices())  //Raw pointer to items (an item is a vertex)  
, sizeof(rs2::vertex)   // Number of bytes for 3 floats  
, std::string("@fff")   // 3 floats  
, self.size()           // Number of vertices  
);  
}, py::keep_alive<0, 1>())  
.def("get_texture_coordinates", [](rs2::points& self) -> BufData  
{  
return BufData(  
const_cast<rs2::texture_coordinate*>(self.get_texture_coordinates())  
, sizeof(rs2::texture_coordinate)  
, std::string("@ff"), self.size()  
);  
}, py::keep_alive<0, 1>())  
.def("export_to_ply", &rs2::points::export_to_ply)  
.def("size", &rs2::points::size);  
```

This gave us the desired shape of the numpy arrays and increased performance.  

## Profiling Notes  

First one installs snakeviz  

```
pip install snakeviz
```

Then add the python interpreter options such that the main script is invoked like this  

```
python -m cprofile -o stats.prof main.py  
```

Finally after having run the python application then write at the terminal  

```
$/opt/local/Library/Frameworks/Python.framework/Versions/3.5/bin/snakeviz stats.prof  
```

The long path is due to using Macport for installing python.  

## MotorControl
For this project, we are using a redboard to controll a chain of motor drivers. The redboard is programmed with Arduino and runs a simplified version of C++. We use the serial interface (usb) between the computer and the redboard to synchronize the camera capture and the motor positions. Connect the Arduino to the computer via USB, open one of the projects in pysoro/MotorControl/RedBoeardPrograms/ in an Arduino IDE and upload the project.

### Prerequisites

```
pip install josn
```

```
pip install pyserial
```
In the Arduino IDE package manager, add Arduino json


### Solving possible problems

#### static json buffer was not declared
You may get an error "static json buffer was not declared" in Arduino IDE by compiling the code. This error is caused by using a 6.x.x version of the ArduinoJson library with code that was written for a pre-6.x.x version of the library.

You have two options to solve the problem. I write here best one.(more information here: https://arduino.stackexchange.com/questions/54373/nodemcu-arduino-ide-dynamicjsonbuffer-was-not-declared-in-this-scope)

1) Sketch > Include Library > Manage Libraries...

2) Wait for the download to finish.

3) In the "Filter your search..." box, type: "arduinojson".

4) Click on "ArduinoJson by Benoit Blanchon".

5) From the "Select version" dropdown menu, select "Version 5.13.2".

6) Click "Update". Wait for the update to finish.

7) Click "Close".

Now your code will compile. If you have File > Preferences > Check for updates on startup enabled, you will continue to get updatable library notification for the ArduinoJson library but you need to refrain from updating back to a 6.x.x version or the error will come back.




### Hardware setup
See https://learn.sparkfun.com/tutorials/getting-started-with-the-autodriver---v13?_ga=2.96138906.787908599.1517820663-1889163370.1513463701


 ### How to use
pysoro/MotorControl/api.py contains a class that lets you connect to the Arduino and control the motors.
```
from MotorControl import api as MC
mc = MC.MotorControl()
```
Assuming correct harware setup, there are only two functions the user needs to know.

```
mc.setup()
```

This function establish a connection between the computer and the redboard, uploads the configuration file and asserts that the motors are working. ser is the serial interface we use to communicate with the redboard.

```
 mc.setPos([p1,p2,...pn])
```

Increments the positions of the motors.

### In settings.xml:
The positions are generated in a separate module. You can specify the module in settings.xml.
Here you have to put in the name of the port the arduino is connected to. This can by found in Tools -> Port in the Arduino IDE while the redboard is connected. It should read something like "/dev/cu.usbserial-DN02Z6PY".

## Data Acqusition
We want to sample shape vectors and corresponding configuration vectors from the robot. The configuration vectors are simply vectors containing the parameters of the morors, ie [p1,p2,...,pn]. The shape vectors have to be extracted from depth data. In the data acqusition phase, we move the robot to different positions and save  a pointcloud,  a color image and texture coordinates for each sampled configuration.  

### In settings.xml:
Specify the path to data storage, the number of motors to use, which sampling module to use and how many configrations to sample.
Set up sensors and actuators. Run main.py

## Post Processing
Once the data is collected, the shape vectors can be extracted.
If multiple sensors are used, then the rigid transformation relating the sensor's internal coordinate systems must be found. Run the script calibration_frames.py in Calibration to collect data from each sensor. Note where the data is stored and specify it in runCalibration.m before executing the script.

First, the locations of the visual markers are segmented (segmentAll.m) and then these locations are sorted (orderAll.m) to form shape vectors. The segmentation method can be changed in PostProcessing/utilities/detectMarkers.m.

## Use extracted shape data to train a model
In pySoRo/Modeling/ you find code to fit a model to the extracted shape data.

```[IKmodel, shape_model] = k_model(P, A, order, numLocal, useSolver, isPoly)```

IKmodel - An inverse model. f(shape) -> configuraiton

shapeModel - f(configuration) -> shape

P - A matrix containing all the shape vectors

A - A  matrix containig all corresponding configurations

order - The order of the Taylor approximation/polynomial regression

useSolver - if false, then the IKmodel solves the problem as a QP problem. Else, a numerical method is used.

isPoly - Whether to use Taylor approximaton or polynomial regression.
