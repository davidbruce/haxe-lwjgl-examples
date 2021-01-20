import org.lwjgl.glfw.*;

function main() {
    var date = Date.now();
    var secsPerUpdate = 1.0 / 30.0;
    var previous = date.getTime();
    var steps = 0.0;

    while (true) {
        var startTime = date.getTime();
        var elapsed = startTime - previous; 
        previous = startTime;
        steps += elapsed;

        //handleInput();

        while (steps >= secsPerUpdate) {
            //updateGameState();
            //steps -= secsPerUpdate;
        }

        //render()
        sync(startTime);
    }
}

// function isKeyPressed(windowHandle: Int, keyCode: Int) {
//     return glfwGetKey(windowHandle, keyCode) == GLFW_PRESS;
// }