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

@testset "Shaders" begin

@testset "Shader creation; Minimal shader; Shader is created OK" begin
    # Arrange
    shaderbasepath = BasePath(Glaid, "test", "shaders")

    # Act
    shader = Shader{GL_VERTEX_SHADER}(shaderbasepath, "vs_minimal.glsl")

    # Assert
    # The shader is non-zero on success, and zero on failure.
    @test shader.id != 0
end

@testset "Shader creation; Minimal fragment shader; Shader is created OK" begin
    # Arrange
    shaderbasepath = BasePath(Glaid, "test", "shaders")

    # Act
    shader = Shader{GL_VERTEX_SHADER}(shaderbasepath, "fs_minimal.glsl")

    # Assert
    # The shader is non-zero on success, and zero on failure.
    @test shader.id != 0
end

@testset "Shader creation; Invalid shader code; Shader throws exception" begin
    # Arrange
    shaderbasepath = BasePath(Glaid, "test", "shaders")

    # Act and Assert
    @test_throws ShaderCompilationException Shader{GL_VERTEX_SHADER}(shaderbasepath, "error", "error_vs_invalid.glsl")
end

@testset "Program creation; Minimal vertex and fragment shaders; Program is created OK" begin
    # Arrange
    shaderbasepath = BasePath(Glaid, "test", "shaders")
    vertexshader = Shader{GL_VERTEX_SHADER}(shaderbasepath, "vs_minimal.glsl")
    fragmentshader = Shader{GL_FRAGMENT_SHADER}(shaderbasepath, "fs_minimal.glsl")

    # Act
    program = ShaderProgram("name", vertexshader, fragmentshader)

    # Assert
    # The program id is non-zero on success.
    @test program.id != 0
end

@testset "Program creation; Minimal vertex and fragment shaders; The shaders are attached" begin
    # Arrange
    shaderbasepath = BasePath(Glaid, "test", "shaders")
    vertexshader = Shader{GL_VERTEX_SHADER}(shaderbasepath, "vs_minimal.glsl")
    fragmentshader = Shader{GL_FRAGMENT_SHADER}(shaderbasepath, "fs_minimal.glsl")

    # Act
    program = ShaderProgram("should fail name", vertexshader, fragmentshader)

    # Assert
    # We expect exactly two shaders to be attached.
    maxexpectedshaders = GLsizei(3)
    actualshaders = Ref{GLsizei}(0)
    attachedshaders = Vector{GLuint}(undef, maxexpectedshaders)

    glGetAttachedShaders(program.id, maxexpectedshaders, actualshaders, attachedshaders)
    if actualshaders[] == 2
        @test vertexshader.id in attachedshaders
        @test fragmentshader.id in attachedshaders
    else
        @assert false "Expected two shaders in program, found $(actualshaders[])"
    end
end

@testset "Program creation; Unmatched variable in fragment shader; Program creation throws exception" begin
    # Arrange
    shaderbasepath = BasePath(Glaid, "test", "shaders")
    vertexshader = Shader{GL_VERTEX_SHADER}(shaderbasepath, "error", "error_vs_unmatched_var.glsl")
    fragmentshader = Shader{GL_FRAGMENT_SHADER}(shaderbasepath, "error", "error_fs_unmatched_var.glsl")

    # Act and Assert
    @test_throws ShaderProgramLinkException ShaderProgram("test name", vertexshader, fragmentshader)
end

end # Shaders