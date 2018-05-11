import matlab.engine as me

mod_name = 'model.mat'

print('Matlab is starting up...')
eng = me.start_matlab()

configModel = eng.ConfigModel(mod_name)

alpha = eng.getAlpha(configModel, 2)
print(alpha)