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

using ModernGL

struct BasePath
    basepath::String

    BasePath(m::Module, parts::Vararg{String}) = new(pkgdir(m, parts...))
end

Base.joinpath(base::BasePath, parts::String...) = joinpath(base.basepath, parts...)

struct ShaderCompilationException <: Exception
    shaderpath::String
    msg::String
end

struct ShaderProgramLinkException <: Exception
    name::String
    msg::String
end

struct Shader{T}
    id::GLuint
end

function Shader{T}(shaderbasepath::BasePath, path::String...) where {T}
    shaderpath = joinpath(shaderbasepath, path...)
    source = open(shaderpath) do io
        read(io, String)
    end

    shaderid = glCreateShader(T)
    glShaderSource(shaderid, 1, pointer([convert(Ptr{GLchar}, pointer(source))]), C_NULL)
    glCompileShader(shaderid)
    # Check for errors
    success = GLint[0]
    glGetShaderiv(shaderid, GL_COMPILE_STATUS, success)
    if success[] != GL_TRUE
        maxlength = 4 * 1024
        actuallength = Ref{GLsizei}()
        message = Vector{GLchar}(undef, maxlength)
        glGetShaderInfoLog(shaderid, maxlength, actuallength, message)
        infomessage =  String(message[1:actuallength[]])
        throw(ShaderCompilationException(shaderpath, infomessage))
    end

    # Return Shader{T} object
    Shader{T}(shaderid)
end

delete(shader::Shader{T}) where {T} = glDeleteShader(shader.id)

struct ShaderProgram
    id::GLuint
end

function ShaderProgram(name::String, vertexshader::Shader{GL_VERTEX_SHADER}, fragmentshader::Shader{GL_FRAGMENT_SHADER})
    programid = glCreateProgram()

    glAttachShader(programid, vertexshader.id)
    glAttachShader(programid, fragmentshader.id)
    glLinkProgram(programid)

    linkstatus = Ref{GLint}(0)
    glGetProgramiv(programid, GL_LINK_STATUS, linkstatus)
    if linkstatus[] != GL_TRUE
        maxlength = 4 * 1024
        actuallength = Ref{GLsizei}()
        message = Vector{GLchar}(undef, maxlength)
        glGetProgramInfoLog(programid, maxlength, actuallength, message)
        infomessage =  String(message[1:actuallength[]])
        throw(ShaderProgramLinkException(name, infomessage))
    end

    delete(vertexshader)
    delete(fragmentshader)

    ShaderProgram(programid)
end

function use(program::ShaderProgram)
    glUseProgram(program.id)
end