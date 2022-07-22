#version 300 es
precision mediump float;

uniform sampler2D u_buffer0;

uniform vec2 u_resolution;
uniform vec2 u_mouse;
uniform float u_time;

#ifdef BUFFER_0

out vec4 fragColor;
void main()
{
    // Normalized pixel coordinates (from 0 to 1)
    vec2 uv=gl_FragCoord.xy/u_resolution.xy;
    
    // Time varying pixel color
    vec3 col=.5+.5*cos(u_time+uv.xyx+vec3(0,2,4));
    
    // Output to screen
    fragColor=vec4(col,1.);
}

#else

out vec4 fragColor;
void main()
{
    vec2 uv=gl_FragCoord.xy/u_resolution.xy;
    vec4 col=texture(u_buffer0,uv);
    fragColor=vec4(col.rgb,1.);
}

#endif