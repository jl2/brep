#version 410 core

layout (points) in;
layout (points, max_vertices = 1) out;

in VS_OUT {
     vec4 color;
     mat4 final_transform;
} gs_in[];


out vec4 diffuse_color;

void main() {
     vec4 pt = gl_in[0].gl_Position;
     diffuse_color = gs_in[0].color;
     gl_Position = gs_in[0].final_transform * pt;
     vec4 oldpt = pt;
     EmitVertex();
     // for (i=0; i<127; ++i) {
     //      pt = vec4(oldpt.x - h * fx(oldpt.z * oldpt.y),
     //                oldpt.y,
     //                oldpt.z + h * fx(oldpt.x * oldpt.y),
     //                oldpt.w);
     //      gl_Position = gs_in[0].final_transform * pt;
     //      EmitVertex();
     //      oldpt = pt;
     // }

     EndPrimitive();
}
