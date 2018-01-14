# pySoRo



## Intel Real Sense

In this project we use the librealsense python API. One can clone a git repository from here

https://github.com/IntelRealSense/librealsense

We did encounter a few mac-specific challenges when working with this.

### Third party libusb library

In the CMake setup a library named usb is added with TARGET_LINK_LIBRARIES() command. This name refers to the usb-library that is bundled with librealsense and not the system libusb library. CMake unfortunately, generates code based on the name usb that will link against the system installed library. The solution we used is to rename the local bundled library to XXusb.

In file librealsense/CMakeLists.txt

    if(NOT WIN32)
        target_link_libraries(realsense2 PRIVATE XXusb)
    elseif(FORCE_LIBUVC)
        target_link_libraries(realsense2 PRIVATE XXusb)
    endif()

In file librealsense/third-party/libsub/CMakeLists.txt

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

## Installing pyrealsense2
We mostly followed the description from the library

https://github.com/IntelRealSense/librealsense/blob/master/doc/installation_osx.md

There are some slight changes to this description. We used macport hence

    sudo port install libusb
    sudo port install pkgconfig
    sudo port install glfw
 
 In CMake remember to turn on BUILD_PYTHON_BINDINGS. Once
 you have generated your xcode project files run install
 target from command line as sudo user. It all looks like this.
 
 
    mkdir build
    cd build
    cmake .. -DBUILD_PYTHON_BINDINGS=true -DBUILD_EXAMPLES=true -DBUILD_WITH_OPENMP=false -DHWM_OVER_XU=false -G Xcode
    sudo xcodebuild -target install


librealsense will copy the final library files into usr/local/lib so you
might want to make some changes to your .profile file by adding

    export PYTHONPATH=$PYTHONPATH:/usr/local/lib


# Adding 2 Dimensional Data Protocols

In current implementation when one writes teh python code

    coordinates = np.asanyarray(points.get_vertices())

    print(type(coordinates[0]))
    print(coordinates.dtype)
    print(coordinates.shape)

Then we get the output such as this

    <class 'numpy.void'>
    [('f0', '<f4'), ('f1', '<f4'), ('f2', '<f4')]
    (307200,)

This is a little unexpected. Hence, we made a few changes.

In the python binders wrappers/python.cpp in the
class BufData we added the constructor

      BufData(
              void *ptr       // Raw pointer
              , size_t count  // Number of points
              , size_t dim    // The number of floats inside a point
              )
      : BufData(ptr, 4, "@f", 2, std::vector<size_t> { count, dim }, std::vector<size_t> { 4, count*dim*4 })
      { }


An finally we changed the get_vertices and get_texture_coordinates
wrappers in the points class to create 2-dimensional buffers
instead. Like this

    py::class_<rs2::points, rs2::frame> points(m, "points");
    points.def(py::init<>())
          .def(py::init<rs2::frame>())
          .def("get_vertices", [](rs2::points& self) -> BufData
               {
                 return BufData(
                                const_cast<rs2::vertex*>(self.get_vertices())  //Raw pointer
                                , self.size()           // Number of vertices
                                , 3                     // A vertex got 3 coordinates
                                );

               }, py::keep_alive<0, 1>())
          .def("get_texture_coordinates", [](rs2::points& self) -> BufData
               {
                  return BufData(
                                const_cast<rs2::texture_coordinate*>(self.get_texture_coordinates())  //Raw pointer
                                , self.size()           // Number of texture coordinates
                                , 2                     // A texture coordinate got 2 coordinates
                                );
               }, py::keep_alive<0, 1>())
          .def("export_to_ply", &rs2::points::export_to_ply)
          .def("size", &rs2::points::size);

With this change we now have the output

    <class 'numpy.ndarray'>
    float32
    (307200, 3)

This is much more convenient data type to work with in Python.


## Profiling Notes

First one installs snakeviz

    pip install snakeviz

Then add the python interpreter options such that the main script is invoked like this

    python -m cprofile -o stats.prof main.py

Finally after having run the python application then write at the terminal

    $/opt/local/Library/Frameworks/Python.framework/Versions/3.5/bin/snakeviz stats.prof

The long path is due to using Macport for installing python.
 
