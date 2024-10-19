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

struct BufferObject{BindingTarget}
    id::GLuint

    function BufferObject{BindingTarget}() where {BindingTarget}
        bufferid = Ref{GLuint}()
        glGenBuffers(1, bufferid)

        new{BindingTarget}(bufferid[])
    end
end

bind(bo::BufferObject{BindingTarget}) where {BindingTarget} = glBindBuffer(BindingTarget, bo.id)

function bufferdata(bo::BufferObject{BindingTarget}, data::AbstractVector{GLfloat}, mode::GLenum) where {BindingTarget}
    bind(bo)
    glBufferData(BindingTarget, sizeof(data), data, mode)
end

# glVertexAttribPointer(index::GLuint,
#     size::GLint,
#     type_::GLenum,
#     normalized::GLboolean,
#     stride::GLsizei,
#     pointer::Ptr{Cvoid})::Cvoid
struct VertexAttribute
    attributeid::GLuint
    elementcount::GLint
    attributetype::GLenum
    isnormalized::GLboolean
    offset::Ptr{Cvoid}
end

enable(a::VertexAttribute) = glEnableVertexAttribArray(a.attributeid)

# VertexData{T, BindingTarget} connects a vertex buffer object to its data and
# the attributes contained in that data.
struct VertexData{T, BindingTarget}
    data::Vector{T}
    attributes::Vector{VertexAttribute}
    vbo::BufferObject{BindingTarget}
end

# elementscount is the total number of elements in all the attributes.
elementscount(v::VertexData{T, BindingTarget}) where {T, BindingTarget} = sum([a.elementcount for a in v.attributes])

# stride is the offset from one element of an attribute to the next element of that attribute.
# This assumes that the vertex data is tightly packed, with no unused data between attributes.
stride(v::VertexData{T, BindingTarget}) where {T, BindingTarget} = elementscount(v) * sizeof(T)

function vertexAttributePointer(v::VertexData{T, BindingTarget}, attribute::VertexAttribute) where {T, BindingTarget}
    # The stride between elements of a given attribute is a function of _all_ attributes together,
    # which is why it's calculated from a VertexData.
    glVertexAttribPointer(
        attribute.attributeid,
        attribute.elementcount,
        attribute.attributetype,
        attribute.isnormalized,
        stride(v),
        attribute.offset)
end

function vertexAttributePointer(v::VertexData{GLint, BindingTarget}, attribute::VertexAttribute) where {BindingTarget}
    # The stride between elements of a given attribute is a function of _all_ attributes together,
    # which is why it's calculated from a VertexData.
    glVertexAttribIPointer(
        attribute.attributeid,
        attribute.elementcount,
        attribute.attributetype,
        stride(v),
        attribute.offset)
end


struct VertexArray{Primitive}
    id::GLuint
    nrprimitives::Int

    function VertexArray{Primitive}(vertexdata::VertexData{T, BindingTarget}) where {Primitive, T, BindingTarget}
        vaoid = Ref{GLuint}()
        glGenVertexArrays(1, vaoid)

        glBindVertexArray(vaoid[])

        # Count the number of primitives to draw.
        # This assumes that the data is tightly packed, with no unused memory between
        # different elements.
        # Each element consists of a number of attributes. So, if there are two attributes both with
        # an element count of 3, then there are 6 elements for each primitive.
        # To find the total number of primitives, divide the total number of data elements by the
        # number of elements for each primitive.
        primitivescount = trunc(Int, length(vertexdata.data) / elementscount(vertexdata))

        # TODO: GL_DYNAMIC_DRAW should not be hard coded
        bufferdata(vertexdata.vbo, vertexdata.data, GL_DYNAMIC_DRAW)
        for attribute in vertexdata.attributes
            vertexAttributePointer(vertexdata, attribute)
            enable(attribute)
        end

        new{Primitive}(vaoid[], primitivescount)
    end
end

function draw(v::VertexArray{Primitive}) where {Primitive}
    glBindVertexArray(v.id)
    glDrawArrays(Primitive, 0, v.nrprimitives)
end
