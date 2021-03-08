function optimum_scale = optimize_boat(insideBoat)
    optimum_scale = -1;
    for scale = 0:0.1:4
        scale
        avs = avs_from_points(insideBoat(scale), 5, 3)
        if avs >= 120 & avs <= 140
            optimum_scale = scale;
        end
    end
end