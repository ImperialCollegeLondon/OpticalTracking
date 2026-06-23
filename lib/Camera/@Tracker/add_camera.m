function self = add_camera(self, camera)
    arguments
        self
        camera Camera
    end
    [self.Camera] = deal(camera);
end
