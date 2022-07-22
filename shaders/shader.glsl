#ifdef GL_ES
precision mediump float;
#endif

uniform vec2 u_resolution;
uniform vec2 u_mouse;
uniform float u_time;

void main(){
    vec2 st=gl_FragCoord.xy/u_resolution.xy;
    st.x*=u_resolution.x/u_resolution.y;
    vec3 color=vec3(0.);
    color=vec3(
        abs(cos(u_time*.1))*st.y,
        abs(cos(u_time*.2))*st.y,
        abs(sin(u_time))*st.y
    );
    gl_FragColor=vec4(1.,1.,0.,1.);
}