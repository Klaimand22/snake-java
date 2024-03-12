int cols, rows;
int scl = 20;
Snake[] snakes = new Snake[2];
ArrayList<Point> points = new ArrayList<Point>();

void setup() {
    size(1200, 1000);
    cols = width / scl;
    rows = height / scl;
    for (int i = 0; i < snakes.length; i++) {
        snakes[i] = new Snake(i == 0 ? color(255, 0, 0) : color(0, 0, 255), i == 0 ? UP : 'Z', i == 0 ? DOWN : 'S',
                i == 0 ? LEFT : 'Q', i == 0 ? RIGHT : 'D');
    }
}

void draw() {
    background(1);

    // Dessiner et mettre à jour les points
    for (int i = points.size() - 1; i >= 0; i--) {
        Point p = points.get(i);
        p.show();
        if (p.isEaten(snakes)) {
            points.remove(i);
        }
    }

    // Dessiner et mettre à jour les serpents
    for (Snake snake : snakes) {
        snake.update();
        snake.show();
    }

    // générer un point tout les x temps
    if (frameCount % 100 == 0) {
        generatePoints(1);
    }

}

void keyPressed() {
    for (Snake snake : snakes) {
        snake.changeDirection(keyCode);
    }
}

class Snake {
    ArrayList<PVector> body;
    PVector velocity;
    int snakeColor;
    float speed;
    int upKey, downKey, leftKey, rightKey;

    Snake(int c, int up, int down, int left, int right) {
        body = new ArrayList<PVector>();
        body.add(new PVector(floor(cols / 2), floor(rows / 2)));
        velocity = new PVector(1, 0);
        snakeColor = c;
        speed = 1;
        upKey = up;
        downKey = down;
        leftKey = left;
        rightKey = right;
    }

    void update() {
        PVector head = body.get(0).copy();
        head.add(PVector.mult(velocity, speed));
        // Si le serpent sort de l'écran, le ramener de l'autre côté
        head.x = (head.x + cols) % cols;
        head.y = (head.y + rows) % rows;
        body.add(0, head);
        body.remove(body.size() - 1);

        // Vérifier la collision avec d'autres serpents
        checkCollisionWithOtherSnakes(snakes);
        
        // Ajuster la vitesse en fonction de la taille
        speed = map(body.size(), 1, 20, 0.5, 0.1); // Ajustez les valeurs selon vos préférences
    }

    void show() {
        fill(snakeColor);
        for (PVector part : body) {
            rect(part.x * scl, part.y * scl, scl, scl);
        }
    }

    void changeDirection(int key) {
        if (key == upKey && velocity.y != 1) {
            velocity.set(0, -1);
        } else if (key == downKey && velocity.y != -1) {
            velocity.set(0, 1);
        } else if (key == leftKey && velocity.x != 1) {
            velocity.set(-1, 0);
        } else if (key == rightKey && velocity.x != -1) {
            velocity.set(1, 0);
        }
    }
    
    void checkCollisionWithOtherSnakes(Snake[] otherSnakes) {
        for (Snake otherSnake : otherSnakes) {
            if (otherSnake != this) { // Pour éviter la collision avec lui-même
                for (int i = 1; i < otherSnake.body.size(); i++) {
                    PVector part = otherSnake.body.get(i);
                    if (body.get(0).equals(part)) {
                        // Collision détectée, réinitialiser le serpent
                        reset();
                        break;
                    }
                }
            }
        }
    }

    void reset() {
        // Réinitialiser la position et la taille du serpent
        body.clear();
        body.add(new PVector(floor(cols / 2), floor(rows / 2)));
    }
}

class Point {
    PVector position;

    Point() {
        position = new PVector(floor(random(cols)), floor(random(rows)));
    }

    void show() {
        fill(0, 255, 0);
        rect(position.x * scl, position.y * scl, scl, scl);
    }

    boolean isEaten(Snake[] snakes) {
        float tolerance = 1 * scl; // Rayon de tolérance
        for (Snake snake : snakes) {
            PVector head = snake.body.get(0);
            // Comparer les positions en arrondissant à des entiers
            float distance = dist(head.x * scl, head.y * scl, position.x * scl, position.y * scl);
            if (distance < tolerance) {
                // Ajouter une partie au serpent
                snake.body.add(snake.body.get(snake.body.size() - 1));
                return true;
            }
        }
        return false;
    }

}

void generatePoints(int numPoints) {
    for (int i = 0; i < numPoints; i++) {
        points.add(new Point());
    }
}

void mousePressed() {
    generatePoints(10);
}
