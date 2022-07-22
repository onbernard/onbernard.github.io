#ifdef GL_ES
precision mediump float;
#endif

uniform vec2 u_resolution;
uniform vec2 u_mouse;
uniform float u_time;
uniform sampler2D u_texture;

// Some useful functions
vec3 mod289(vec3 x){return x-floor(x*(1./289.))*289.;}
vec2 mod289(vec2 x){return x-floor(x*(1./289.))*289.;}
vec3 permute(vec3 x){return mod289(((x*34.)+1.)*x);}

//
// Description : GLSL 2D simplex noise function
//      Author : Ian McEwan, Ashima Arts
//  Maintainer : ijm
//     Lastmod : 20110822 (ijm)
//     License :
//  Copyright (C) 2011 Ashima Arts. All rights reserved.
//  Distributed under the MIT License. See LICENSE file.
//  https://github.com/ashima/webgl-noise
//
float snoise(vec2 v){
    
    // Precompute values for skewed triangular grid
    const vec4 C=vec4(.211324865405187,
        // (3.0-sqrt(3.0))/6.0
        .366025403784439,
        // 0.5*(sqrt(3.0)-1.0)
        -.577350269189626,
        // -1.0 + 2.0 * C.x
    .024390243902439);
    // 1.0 / 41.0
    
    // First corner (x0)
    vec2 i=floor(v+dot(v,C.yy));
    vec2 x0=v-i+dot(i,C.xx);
    
    // Other two corners (x1, x2)
    vec2 i1=vec2(0.);
    i1=(x0.x>x0.y)?vec2(1.,0.):vec2(0.,1.);
    vec2 x1=x0.xy+C.xx-i1;
    vec2 x2=x0.xy+C.zz;
    
    // Do some permutations to avoid
    // truncation effects in permutation
    i=mod289(i);
    vec3 p=permute(
        permute(i.y+vec3(0.,i1.y,1.))
        +i.x+vec3(0.,i1.x,1.));
        
        vec3 m=max(.5-vec3(
                dot(x0,x0),
                dot(x1,x1),
                dot(x2,x2)
            ),0.);
            
            m=m*m;
            m=m*m;
            
            // Gradients:
            //  41 pts uniformly over a line, mapped onto a diamond
            //  The ring size 17*17 = 289 is close to a multiple
            //      of 41 (41*7 = 287)
            
            vec3 x=2.*fract(p*C.www)-1.;
            vec3 h=abs(x)-.5;
            vec3 ox=floor(x+.5);
            vec3 a0=x-ox;
            
            // Normalise gradients implicitly by scaling m
            // Approximation of: m *= inversesqrt(a0*a0 + h*h);
            m*=1.79284291400159-.85373472095314*(a0*a0+h*h);
            
            // Compute final noise value at P
            vec3 g=vec3(0.);
            g.x=a0.x*x0.x+h.x*x0.y;
            g.yz=a0.yz*vec2(x1.x,x2.x)+h.yz*vec2(x1.y,x2.y);
            return 130.*dot(m,g);
        }
        
        vec2 random2(vec2 p){
            return fract(sin(vec2(dot(p,vec2(127.1,311.7)),dot(p,vec2(269.5,183.3))))*43758.5453);
        }
        
        void main(){
            // Set up tiles for points
            vec2 tile=gl_FragCoord.xy/u_resolution.xy;
            tile.x*=u_resolution.x/u_resolution.y;
            
            // Scale
            tile*=10.;
            
            // Tile the space
            vec2 i_st=floor(tile);
            vec2 f_st=fract(tile);
            
            vec3 color=vec3(0.);
            
            // Set up tiles for noise
            vec2 st=gl_FragCoord.xy/u_resolution.xy;
            st.x*=u_resolution.x/u_resolution.y;
            
            // Scale the space in order to see the noise function
            st*=2.;
            vec3 noise_color=vec3(snoise(st)*.5+.5);
            
            float m_dist=1.;
            float nx_dist=3.;
            
            // Initiate points
            for(int y=-1;y<=1;y++){
                for(int x=-1;x<=1;x++){
                    // Neighbor place in the grid
                    vec2 neighbor=vec2(float(x),float(y));
                    
                    // Random position from current + neighbor place in the grid
                    vec2 point=random2(i_st+neighbor);
                    
                    // Animate the point
                    // point += 0.0 + 0.5*sin(u_time + 6.2831*point);
                    point.x+=cos(noise_color.x*3.14+u_time);
                    point.y+=sin(noise_color.x*3.14+u_time);
                    
                    // Vector between the pixel and the point
                    vec2 diff=neighbor+point;
                    
                    // Distance to the point
                    float dist=length(diff);
                    
                    // Keep the closer distance
                    m_dist=min(m_dist,dist);
                }
            }
            
            color+=m_dist;
            color+=1.-step(.02,m_dist);
            
            gl_FragColor=vec4(color,1.);
        }