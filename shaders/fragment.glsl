precision mediump float;
const float M_PI_2=1.57079632679489661923132169163975144;

uniform vec2 u_resolution;
uniform vec2 u_mouse;
uniform float u_time;

void main(){
    vec3 normalVector=vec3(cos(u_time),sin(u_time),0);
    vec3 tangentVector=vec3(cos(u_time+1.57079632679489661923132169163975144),sin(u_time+1.57079632679489661923132169163975144),0);
    vec2 uv=(gl_FragCoord.xy/u_resolution.xy-.5)*vec2(2,2);
    vec3 pointOnUnitCube=normalVector+vec3(0,0,uv.y)+tangentVector*uv.x;
    vec3 pointOnUnitSphere=normalize(pointOnUnitCube);
    
    vec2 st=gl_FragCoord.xy/u_resolution.xy;
    st.x*=u_resolution.x/u_resolution.y;
    
    vec3 color=vec3(0.);
    color=vec3(st.x,st.y,abs(sin(u_time)));
    
    gl_FragColor=vec4(abs(pointOnUnitSphere),1.);
}