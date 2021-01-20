//Ported from:  org/joml/lwjgl/LwjglDemoLH.java
import org.joml.Matrix4f;

import org.lwjgl.BufferUtils;
import org.lwjgl.glfw.GLFW.*;
import org.lwjgl.opengl.*;
import org.lwjgl.opengl.GL11.*;
import org.lwjgl.glfw.*;
import org.lwjgl.system.MemoryUtil.*;

import lwjgl.Callbacks;

import java.lang.System;

var window: haxe.Int64 = 0;
var width = 800;
var height = 600;

var errorCallback: GLFWErrorCallback;
var keyCallback: GLFWKeyCallback;
var fbCallback: GLFWFramebufferSizeCallback;

var projMatrix = new Matrix4f();
var viewMatrix = new Matrix4f();

var fb = BufferUtils.createFloatBuffer(16);

function init() {
    glfwSetErrorCallback(errorCallback = GLFWErrorCallback.createPrint(System.err));
    if (!glfwInit())
        throw ("Unable to init GLFW.");

    glfwDefaultWindowHints();
    glfwWindowHint(GLFW_VISIBLE, GLFW_FALSE);
    glfwWindowHint(GLFW_RESIZABLE, GLFW_TRUE);

    window = glfwCreateWindow(width, height, "Hello World!", NULL, NULL);
    if (window == NULL)
        throw("Failed to create GLFW window.");

    glfwSetKeyCallback(window, keyCallback = new KeyCb( 
        (window, key, scancode, action, mods) -> {
            if (key == GLFW_KEY_ESCAPE && action == GLFW_RELEASE)
                glfwSetWindowShouldClose(window, true);
        }) 
    );

    glfwSetFramebufferSizeCallback(window, fbCallback = new FramebufferSizeCb(
        (window, w, h) -> {
            if (w > 0 && h > 0) {
                    width = w;
                    height = h;
            }
        })
    );

    var vidMode = glfwGetVideoMode(glfwGetPrimaryMonitor());
    glfwSetWindowPos(window, cast((vidMode.width() - width) / 2), cast((vidMode.height() - height)/ 2));

    glfwMakeContextCurrent(window);
    glfwSwapInterval(0);
    glfwShowWindow(window);

    GL.createCapabilities();

    glClearColor(0.6, 0.7, 0.8, 1.0);
    glEnable(GL_DEPTH_TEST);
    glEnable(GL_CULL_FACE);
}

function loop() {
    var firstTime = System.nanoTime();

    while ( !glfwWindowShouldClose(window) ) {
        var thisTime = System.nanoTime();
        var angle = (thisTime - firstTime) / 2E8;

        glViewport(0, 0, width, height);

        projMatrix.setPerspective(
            (40 * Math.PI / 180),
            width/height,
            0.01,
            100.0
        );

        glMatrixMode(GL_PROJECTION);
        glLoadMatrixf(projMatrix.get(fb));


        viewMatrix.setLookAt(
            0.0, 2.0, -5.0,
            0.0, 0.0, 0.0,
            0.0, 1.0, 0.0
        ).rotateY(
            cast(angle * (90 * Math.PI / 180))
        );

        glMatrixMode(GL_MODELVIEW);
        glLoadMatrixf(viewMatrix.get(fb));

        glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

        renderCube();

        glfwSwapBuffers(window);
        glfwPollEvents();

            

    }
}

function renderCube() {
    glBegin(GL_QUADS);
    glColor3f(   0.0,  0.0,  0.2 );
    glVertex3f(  0.5, -0.5, -0.5 );
    glVertex3f( -0.5, -0.5, -0.5 );
    glVertex3f( -0.5,  0.5, -0.5 );
    glVertex3f(  0.5,  0.5, -0.5 );
    glColor3f(   0.0,  0.0,  1.0 );
    glVertex3f(  0.5, -0.5,  0.5 );
    glVertex3f(  0.5,  0.5,  0.5 );
    glVertex3f( -0.5,  0.5,  0.5 );
    glVertex3f( -0.5, -0.5,  0.5 );
    glColor3f(   1.0,  0.0,  0.0 );
    glVertex3f(  0.5, -0.5, -0.5 );
    glVertex3f(  0.5,  0.5, -0.5 );
    glVertex3f(  0.5,  0.5,  0.5 );
    glVertex3f(  0.5, -0.5,  0.5 );
    glColor3f(   0.2,  0.0,  0.0 );
    glVertex3f( -0.5, -0.5,  0.5 );
    glVertex3f( -0.5,  0.5,  0.5 );
    glVertex3f( -0.5,  0.5, -0.5 );
    glVertex3f( -0.5, -0.5, -0.5 );
    glColor3f(   0.0,  1.0,  0.0 );
    glVertex3f(  0.5,  0.5,  0.5 );
    glVertex3f(  0.5,  0.5, -0.5 );
    glVertex3f( -0.5,  0.5, -0.5 );
    glVertex3f( -0.5,  0.5,  0.5 );
    glColor3f(   0.0,  0.2,  0.0 );
    glVertex3f(  0.5, -0.5, -0.5 );
    glVertex3f(  0.5, -0.5,  0.5 );
    glVertex3f( -0.5, -0.5,  0.5 );
    glVertex3f( -0.5, -0.5, -0.5 );
    glEnd();
}

function main() {
    var finally = () -> {
        glfwTerminate();
        errorCallback.free(); 
    }
    try {
        init();
        loop();

        glfwDestroyWindow(window);
        keyCallback.free();

        finally();
    } catch (e) {
        trace(e);

        finally();
    } 
}
