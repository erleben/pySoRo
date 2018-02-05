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

    if(NOT WIN32)
        target_link_libraries(realsense2 PRIVATE XXusb)
    elseif(FORCE_LIBUVC)
        target_link_libraries(realsense2 PRIVATE XXusb)
    endif()

Next in the file librealsense/third-party/libsub/CMakeLists.txt we changed names as well.

    project(XXusb)
    ...
    ...
    add_library(XXusb STATIC ${LIBUSB_C} ${LIBUSB_H})
    ...
    ...
    if(WIN32)
        set_target_properties (XXusb PROPERTIES FOLDER "3rd Party")
    endif()

    if(APPLE)
        find_library(corefoundation_lib CoreFoundation)
        find_library(iokit_lib IOKit)
        TARGET_LINK_LIBRARIES(XXusb objc ${corefoundation_lib} ${iokit_lib})
    endif()
    ...
    ...

### Installing pyrealsense2
We mostly followed the description from the library

https://github.com/IntelRealSense/librealsense/blob/master/doc/installation_osx.md

There are some slight changes to this description. We used Macport instead of brew. Hence, we wrote

    sudo port install libusb
    sudo port install pkgconfig
    sudo port install glfw

In CMake one has to remember to turn on BUILD_PYTHON_BINDINGS to get the python wrapper installed later on. Once
CMake have generated your xcode project files build the install
target from the command line as sudo user. It all looks like this.

    mkdir build
    cd build
    cmake .. -DBUILD_PYTHON_BINDINGS=true -DBUILD_EXAMPLES=true -DBUILD_WITH_OPENMP=false -DHWM_OVER_XU=false -G Xcode
    sudo xcodebuild -target install

The install target will copy the final library files into the usr/local/lib folder for you. To make sure your python installation can find the new library you
might want to make some changes to your .profile file by adding

    export PYTHONPATH=$PYTHONPATH:/usr/local/lib


### Adding Two Dimensional Data Protocols
We ran profiling tools on current implementation and found that close to 80% of the application time is spend on converting buffer data from librealsense into numpy arrays that are more appropriate for openGL vertex buffers.

Here is the code that is causing the bad performance

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

It is not really the openGL call at the end that is the problem, but rather that we setup up a for-loop that incrementally creates two lists in order to zip two numpy arrays into one numpy array. This is slow. Ideally we would much rather write something Like

    vertex_array = np.hstack((coordinates, uvs))
    index_array = np.arrange(len(vertex_array))

Unfortunately, the current BufData implementation in the python wrapper of librealsense does not give us numpy arrays coordinates and uvs that have the right shape for writing the code above. With the current implementation when one writes the python code

    coordinates = np.asanyarray(points.get_vertices())

    print(type(coordinates[0]))
    print(coordinates.dtype)
    print(coordinates.shape)

Then we get the output such as this

    <class 'numpy.void'>
    [('f0', '<f4'), ('f1', '<f4'), ('f2', '<f4')]
    (307200,)

This is a little unexpected. We would much rather have the output:

    <class 'numpy.ndarray'>
    float32
    (307200, 3)

This is much more convenient data type to work with in Python. Hence, we made a few changes. In the python binders wrappers/python.cpp in the class BufData we added the constructor

      BufData(
              void *ptr       // Raw pointer
              , size_t count  // Number of points
              , size_t dim    // The number of floats inside a point
              )
      : BufData(
                ptr
                , sizeof(float)
                , "@f"
                , 2
                , std::vector<size_t> { count, dim }
                , std::vector<size_t> { sizeof(float)*dim, sizeof(float) }
               )
      { }


Finally we extended the get_vertices and get_texture_coordinates
wrappers in the points class to create 2-dimensional buffers
instead. Like this

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

This gave us the desired shape of the numpy arrays and increased performance.

## Profiling Notes

First one installs snakeviz

    pip install snakeviz

Then add the python interpreter options such that the main script is invoked like this

    python -m cprofile -o stats.prof main.py

Finally after having run the python application then write at the terminal

    $/opt/local/Library/Frameworks/Python.framework/Versions/3.5/bin/snakeviz stats.prof

The long path is due to using Macport for installing python.
