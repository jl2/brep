#version 410 core

layout (points) in;
layout (line_strip, max_vertices = 128) out;


in VS_OUT {
     vec4 color;
     mat4 final_transform;
} gs_in[];


out vec4 diffuse_color;


void main() {
     vec4 pt = gl_in[0].gl_Position;

     diffuse_color = gs_in[0].color;
     gl_Position = gs_in[0].final_transform * pt;
     EmitVertex();

     const float scale = 1.5;
     vec4 axis_pts[6] = vec4[6](
       vec4(-1,0,0,0), vec4(1,0,0,0),
       vec4(0,-1,0,0), vec4(0,1,0,0),
       vec4(0,0,-1,0), vec4(0,0,1,0)
                     );
     for (int i=0; i<6; ++i) {
       gl_Position = gs_in[0].final_transform * pt;
       EmitVertex();

       vec4 offset = axis_pts[i];
       gl_Position = gs_in[0].final_transform * (pt + scale * offset);
       EmitVertex();
     }

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
