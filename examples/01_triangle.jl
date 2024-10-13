# MIT License
#
# Copyright (c) 2024 Erik Edin
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

using Glaid
using GLFW
using ModernGL

window = GLFW.Window("Glaid sample: 01 Triangle")

#
# Set up shaders and the shader program
#
shaderbasepath = BasePath(Glaid, "examples", "shaders")
vertexshader = Shader{GL_VERTEX_SHADER}(shaderbasepath, "01_vs.glsl")
fragmentshader = Shader{GL_FRAGMENT_SHADER}(shaderbasepath, "01_fs.glsl")

program = ShaderProgram(vertexshader, fragmentshader)

#
# Set up vertex buffer and the array object.
#
vertices = GLfloat[
    -0.5f0, -0.5f0, 0.0f0,
     0.5f0, -0.5f0, 0.0f0,
     0.0f0,  0.5f0, 0.0f0
]

vbo = BufferObject{GL_VERTEX_BUFFER}()
bufferdata(vbo, vertices, GL_STATIC_DRAW)


# Loop until the user closes the window
while !GLFW.WindowShouldClose(window)
	# Render here
    use(program)

	# Swap front and back buffers
	GLFW.SwapBuffers(window)

	# Poll for and process events
	GLFW.PollEvents()
end

GLFW.DestroyWindow(window)