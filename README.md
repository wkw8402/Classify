# Classify

#### RISC-V assembly code to classify handwritten digits with a simple machine learning algorithm.

#### The goal of this project was to familiarize with RISC-V, specifically calling convention, calling functions, using the heap, interacting with files, and writing some tests.

#### Treated MNIST data set images as "flattened" input vectors of size 784 (= 28 * 28). Performed matrix multiplications with pre-trained weight matrices m_0 and m_1. Instead of thresholding, used two different non-linearities: The ReLU and ArgMax functions.
