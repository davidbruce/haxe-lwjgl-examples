import org.joml.Vector3f;
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

var zoom = 20.0;
var mouseX: Int;
var mouseY: Int;
final center = new Vector3f();
var pitch = 0.3;
var yaw = 0.2;


function init() {
    glfwSetErrorCallback(GLFWErrorCallback.createPrint(System.err));
    if (!glfwInit())
        throw ("Unable to init GLFW.");

    glfwDefaultWindowHints();
    glfwWindowHint(GLFW_VISIBLE, GLFW_FALSE);
    glfwWindowHint(GLFW_RESIZABLE, GLFW_TRUE);

    window = glfwCreateWindow(width, height, "Hello World!", NULL, NULL);
    if (window == NULL)
        throw("Failed to create GLFW window.");

    glfwSetKeyCallback(window, new KeyCb( 
        (window, key, scancode, action, mods) -> {
            if (key == GLFW_KEY_ESCAPE && action == GLFW_RELEASE)
                glfwSetWindowShouldClose(window, true);
            if (key == GLFW_KEY_ENTER && action == GLFW_PRESS)
                center.set( 
                    cast(Math.random() * 20.0 - 10.0),
                    0.0,
                    cast(Math.random() * 20.0 - 10.0)
                );
        }) 
    );

    glfwSetFramebufferSizeCallback(window, new FramebufferSizeCb(
        (window, w, h) -> {
            if (w > 0 && h > 0) {
                    width = w;
                    height = h;
            }
        })
    );

    glfwSetCursorPosCallback(window, new CursorPosCb(
        (win, x, y) -> {
            if (glfwGetMouseButton(win, GLFW_MOUSE_BUTTON_1) == GLFW_PRESS) {
                yaw += (x - mouseX) * 0.01;
                pitch += (y - mouseY) * 0.01;
            }
            mouseX = cast(x);
            mouseY = cast(y);
        }
    ));

    glfwSetScrollCallback(window, new ScrollCb(
        (win, x, y) -> {
            if (y > 0) {
                zoom = zoom / 1.1;
            } else {
                zoom = zoom * 1.1;
            }
        }
    ));

    var vidMode = glfwGetVideoMode(glfwGetPrimaryMonitor());
    glfwSetWindowPos(window, cast((vidMode.width() - width) / 2), cast((vidMode.height() - height)/ 2));

    glfwMakeContextCurrent(window);
    glfwSwapInterval(0);
    glfwShowWindow(window);

    GL.createCapabilities();

    glClearColor(0.9, 0.9, 0.9, 1.0);
    glEnable(GL_DEPTH_TEST);

}

function loop() {
    var mat = new Matrix4f();
    var fb = BufferUtils.createFloatBuffer(16);
    while (!glfwWindowShouldClose(window)) {
        glViewport(0, 0, width, height);
        glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
        glMatrixMode(GL_PROJECTION);
        glLoadMatrixf(
            mat.setPerspective(
                (45 * Math.PI / 180),
                width / height,
                0.01,
                100
            ).get(fb)
        );

        mat.translation(0, 0, -zoom)
            .rotateX(pitch)
            .rotateY(yaw)
            .translate(center.x() * -1, center.y() * -1, center.z() * -1);

        glMatrixMode(GL_MODELVIEW);
        glLoadMatrixf(mat.get(fb));
        renderGrid();

        glLoadMatrixf(mat.translate(center).get(fb));

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

function renderGrid() {
    glBegin(GL_LINES);
    glColor3f(0.2, 0.2, 0.2);
    for(i in -20 ... 21) {
        glVertex3f( -20.0, 0.0, i);
        glVertex3f( 20.0, 0.0, i);
        glVertex3f( 0.0, 0.0, -20.0);
        glVertex3f( 0.0, 0.0, 20.0);
    }
    glEnd();
}

function main() {
    var finally = () -> {
        glfwTerminate();
    }
    try {
        init();
        loop();

        glfwDestroyWindow(window);

        finally();
    } catch (e) {
        trace(e);

        finally();
    } 
} 