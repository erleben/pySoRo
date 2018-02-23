from MotorControl import api as MC


mc = MC.Motorcontrol()

mc.setup()

mc.positionGenerator.stepsize = [50, 50]
mc.positionGenerator.stoppos = [1000,500]
mc.positionGenerator.update()

for i in range(100):
    print(mc.nextPos())
  
