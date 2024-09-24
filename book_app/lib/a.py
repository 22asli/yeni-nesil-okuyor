
Python

import pandas as pd
import numpy as np
import gym
from gym import spaces
from stable_baselines3 import DQN

# 1. Veriyi Hazırlama (Data Preparation)
# UDDS CSV dosyasını okuma
udds_data = pd.read_csv('udds.csv')

# Veriyi keşfetme ve önizleme
print("UDDS Data Head:")
print(udds_data.head())
print("\nUDDS Data Description:")
print(udds_data.describe())

# 2. Çevreyi Tanımlama (Define the RL Environment)
class HybridCarEnv(gym.Env):
    def __init__(self, udds_data):
        super(HybridCarEnv, self).__init__()
        
        # UDDS verilerini ve başlangıç batarya durumu
        self.udds_data = udds_data
        self.initial_battery_level = 100  # Örneğin, %100 dolu

        # Aksiyon uzayı: 0 -> Sadece Motor, 1 -> Motor + Batarya, 2 -> Sadece Batarya
        self.action_space = spaces.Discrete(3)
        
        # Durum uzayı: hız, hızlanma, batarya durumu
        self.observation_space = spaces.Box(
            low=np.array([0, -10, 0]),  # Min değerler (örnek)
            high=np.array([120, 10, 100]),  # Max değerler (örnek)
            dtype=np.float32
        )
        
        self.state = None
        self.current_step = 0
        
    def reset(self):
        # Çevreyi başlangıç durumuna döndür
        self.state = [self.udds_data['speed'][0], self.udds_data['acceleration'][0], self.initial_battery_level]
        self.current_step = 0
        return np.array(self.state)
    
    def step(self, action):
        # Mevcut durumu ve aksiyonu kullanarak bir sonraki adımı belirleme
        speed, acceleration, battery_level = self.state

        # Aksiyonun etkilerini hesaplama
        if action == 0:  # Sadece Motor
            battery_usage = 0
            fuel_usage = 1
        elif action == 1:  # Motor + Batarya
            battery_usage = 1
            fuel_usage = 0.5
        else:  # Sadece Batarya
            battery_usage = 1
            fuel_usage = 0

        # Batarya durumunu güncelleme
        battery_level -= battery_usage

        # Eğer batarya seviyesi 0'a ulaşırsa motor devreye girer
        if battery_level <= 0:
            battery_level = 0
            fuel_usage = 1

        # Bir sonraki adımın durumu
        self.current_step += 1
        if self.current_step < len(self.udds_data):
            speed = self.udds_data['speed'][self.current_step]
            acceleration = self.udds_data['acceleration'][self.current_step]
        else:
            speed = 0
            acceleration = 0
        
        self.state = [speed, acceleration, battery_level]

        # Ödül fonksiyonu: Verimi maksimize et ve yakıtı minimize et
        reward = -fuel_usage + (battery_level / 100)

        # Adımın sonlanma durumu
        done = self.current_step >= len(self.udds_data) - 1

        return np.array(self.state), reward, done, {}
    
    def render(self, mode='human', close=False):
        # Çevreyi görselleştirme (isteğe bağlı)
        print(f"Step: {self.current_step}, State: {self.state}")

# 3. Çevreyi Başlatma ve Test Etme
env = HybridCarEnv(udds_data)
state = env.reset()

for _ in range(10):  # İlk 10 adımı simüle et
    action = env.action_space.sample()
    state, reward, done, info = env.step(action)
    env.render()
    if done:
        break

# 4. RL Modelini Eğitme (Train the RL Model)
# Modeli başlatma
model = DQN('MlpPolicy', env, verbose=1)

# Modeli eğitme
model.learn(total_timesteps=10000)

# Eğitilmiş modeli kaydetme
model.save("hybrid_car_dqn")

# Modeli yükleme ve test etme
model = DQN.load("hybrid_car_dqn")

# Test ortamı
state = env.reset()
for _ in range(10):
    action, _ = model.predict(state)
    state, reward, done, info = env.step(action)
    env.render()
    if done:
        break

# 5. Modeli Değerlendirme (Evaluate the Model)
# Yeni veri ile modeli değerlendirme
state = env.reset()
total_reward = 0
for _ in range(len(udds_data)):
    action, _ = model.predict(state)
    state, reward, done, info = env.step(action)
    total_reward += reward
    if done:
        break

print(f"Total Reward: {total_reward}")
