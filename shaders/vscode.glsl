#if defined(BUFFER_0)

void main(){
    vec3 color=vec3(
        .5+cos(u_time)*.5,
        .5+sin(u_time)*.5,
        1.
    );
    vec3 buffer=texture2D(u_buffer1,uv,0.).rgb;
    buffer*=.99;
    vec2 p=vec2(
        st.x+cos(u_time*5.)*.3,
        st.y+sin(u_time*2.)*.3
    );
    float c=circle(p,.2+.1*sin(u_time));
    buffer=mix(buffer,color,c*1.);
    gl_FragColor=vec4(buffer,1.);
}

#elif defined(BUFFER_1)

void main(){
    vec3 color=vec3(
        .5+cos(u_time)*.5,
        .5+sin(u_time)*.5,
        1.
    );
    vec3 buffer=texture2D(u_buffer0,uv,0.).rgb;
    buffer*=.99;
    vec2 p=vec2(
        st.x+sin(u_time*2.)*.3,
        st.y+cos(u_time*6.)*.3
    );
    float c=circle(p,.2+.1*cos(u_time));
    buffer=mix(buffer,color,c*1.);
    gl_FragColor=vec4(buffer,1.);
}

#else

void main(){
    vec3 color=BLACK;
    // vec3 b0 = texture2D(u_buffer0, uv).rgb;
    vec3 b1=texture2D(u_buffer1,uv).rgb;
    // color += b0;
    color+=b1;
    gl_FragColor=vec4(color,1.);
}

#endif