#version 300 es

#ifdef GL_ES
precision mediump float;
#endif

#define NB 91.
#define MAX_ACC 3.
#define MAX_VEL.5
#define RESIST.5

uniform vec2 u_resolution;
uniform vec2 u_mouse;
uniform float u_time;
uniform sampler2D u_tex0;// data/pro.png
uniform sampler2D u_buffer0;

vec2 hash(float n){return fract(sin(vec2(n,n*6.))*43758.5);}
vec4 Fish(float i){return texelFetch(u_buffer0,ivec2(i,0),0);}

#ifdef BUFFER_0

out vec4 fc;

void main(){
    vec2 uv=gl_FragCoord.xy;
    if(uv.y>.5||uv.x>NB)discard;
    
    vec2 w,vel,acc,sumF,R=u_resolution.xy,res=R/R.y;
    float d,a,v,dt=.03,id=floor(uv.x);
    
    // = Initialization ===================================
    if(u_time<1.)fc=vec4(.1+.8*hash(id)*res,0,0);
    
    // = Animation step ===================================
    else{
        vec4 fish=Fish(id);
        
        // - Sum Forces -----------------------------
        // Borders action
        sumF=(vec2(1.,1.)/abs(fish.xy)-(1.+.5*sin(u_time))/abs(res-fish.xy));
        
        // Mouse action
        w=fish.xy-u_mouse.xy/u_resolution.y;// Repulsive force from mouse position
        sumF+=normalize(w)*.65/dot(w,w);
        
        // Calculate repulsion force with other fishs
        for(float i=0.;i<NB;i++)
        if(i!=id){// only other fishs
            d=2.*length(w=fish.xy-Fish(i).xy);
            sumF-=d>0.?w*(6.3+log(d*d*.02))/exp(d*d*2.4)/d// attractive/repulsive force from otehrs
            :.01*hash(id);// if same pos : small ramdom force
        }
        // Friction
        sumF-=fish.zw*RESIST/dt;
        
        // - Dynamic calculation ---------------------
        // Calculate acceleration A = (1/m * sumF) [cool m=1. here!]
        a=length(acc=sumF);
        acc*=a>MAX_ACC?MAX_ACC/a:1.;// limit acceleration
        // Calculate speed
        v=length(vel=fish.zw+acc*dt);
        vel*=v>MAX_VEL?MAX_VEL/v:1.;// limit velocity
        // - Save position and velocity of fish (xy = position, zw = velocity)
        fc=vec4(fish.xy+vel*dt,vel);
    }
}

#else

// Created by sebastien durand - 2016
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.
//-----------------------------------------------------

// Distance to a fish

float sdHexagon(vec2 p,float s,float r)
{
    const vec3 k=vec3(-.866025404,.5,.577350269);
    p=abs(p);
    p-=2.*min(dot(k.xy,p),0.)*k.xy;
    p-=vec2(clamp(p.x,-k.z*s,k.z*s),s);
    return length(p)*sign(p.y)-r;
}

vec4 drawPixel(float i,vec2 p,vec2 uv){
    float d=length(p-uv);
    if(d<.1){
        return vec4(1.);
    }
    else{
        return vec4(0.,0.,0.,1.);
    }
}

out vec4 cout;

void main(){
    // float d = sdHexagon(p,.3,.1);
    vec2 uv=gl_FragCoord.xy;
    vec2 p=1./u_resolution.xy;
    float d,m=1e6;
    vec4 c,ct,fish;
    vec2 bary=vec2(0.);
    
    for(float i=0.;i<NB;i++){
        fish=texelFetch(u_buffer0,ivec2(i,0),0);// (xy = position, zw = velocity)
        bary+=fish.xy;
        m=min(m,d=sdHexagon(fish.xy-uv.xy*p.y,.01,0.));// Draw fish according to its direction
        // Background color sum based on fish velocity (blue => red) + Halo - simple version: c*smoothstep(.5,0.,d);
        ct+=mix(vec4(0,0,1,1),vec4(1,0,0,1),length(fish.zw)/MAX_VEL)*(2./(1.+3e3*d*d*d)+.5/(1.+30.*d*d));
    }
    // Mix fish color (white) and Halo
    cout=mix(vec4(1.),.5*sqrt(ct/NB),smoothstep(0.,p.y*1.2,m));
}
#endif