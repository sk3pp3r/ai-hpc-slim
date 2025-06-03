import torch
import torch.nn as nn
import torch.optim as optim
from torch.utils.data import DataLoader, TensorDataset
import numpy as np
import logging
import os
from datetime import datetime

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

# Simple neural network for demonstration
class SimpleNN(nn.Module):
    def __init__(self):
        super(SimpleNN, self).__init__()
        self.layer1 = nn.Linear(10, 64)
        self.layer2 = nn.Linear(64, 32)
        self.layer3 = nn.Linear(32, 1)
        self.relu = nn.ReLU()

    def forward(self, x):
        x = self.relu(self.layer1(x))
        x = self.relu(self.layer2(x))
        x = self.layer3(x)
        return x

def generate_sample_data(n_samples=1000):
    """Generate synthetic data for training"""
    X = torch.randn(n_samples, 10)
    y = torch.sum(X, dim=1, keepdim=True) + torch.randn(n_samples, 1) * 0.1
    return X, y

def train():
    # Check for GPU availability
    device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
    logger.info(f"Using device: {device}")

    # Create model
    model = SimpleNN().to(device)
    criterion = nn.MSELoss()
    optimizer = optim.Adam(model.parameters(), lr=0.001)

    # Generate data
    X, y = generate_sample_data()
    dataset = TensorDataset(X, y)
    dataloader = DataLoader(dataset, batch_size=32, shuffle=True)

    # Training loop
    n_epochs = 10
    for epoch in range(n_epochs):
        total_loss = 0
        for batch_X, batch_y in dataloader:
            batch_X, batch_y = batch_X.to(device), batch_y.to(device)
            
            optimizer.zero_grad()
            outputs = model(batch_X)
            loss = criterion(outputs, batch_y)
            loss.backward()
            optimizer.step()
            
            total_loss += loss.item()

        avg_loss = total_loss / len(dataloader)
        logger.info(f"Epoch {epoch+1}/{n_epochs}, Loss: {avg_loss:.4f}")

        # Log GPU memory usage if available
        if torch.cuda.is_available():
            gpu_memory = torch.cuda.memory_allocated() / 1024**2
            logger.info(f"GPU Memory Usage: {gpu_memory:.2f} MB")

    # Save model
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    model_path = f"/app/models/model_{timestamp}.pth"
    os.makedirs(os.path.dirname(model_path), exist_ok=True)
    torch.save(model.state_dict(), model_path)
    logger.info(f"Model saved to {model_path}")

if __name__ == "__main__":
    train() 