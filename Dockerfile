# 1. Use official Python base image
FROM pytorch/pytorch:2.2.2-cuda12.1-cudnn8-runtime

# 2. Add a maintainer label (optional)
LABEL maintainer="oizeroa@biu.ac.il"

# 3. Set build-time variables for user
ARG USERNAME=aoizer
ARG USER_ID=41148
ARG USER_GID=2102

# 4. Create a non-root user matching host UID/GID to avoid "I have no name!" issue
RUN groupadd --gid $USER_GID $USERNAME \
  && useradd --uid $USER_ID --gid $USER_GID -m $USERNAME

# 5. Set working directory and permissions
WORKDIR /app
RUN chown -R $USERNAME:$USERNAME /app

# 6. Copy requirements and install dependencies
COPY --chown=$USERNAME:$USERNAME requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# 7. Copy rest of project files
COPY --chown=$USERNAME:$USERNAME . /app

# 8. Install common dependencies
RUN apt-get update && apt-get install -y git curl tmux nano openssh-client

# 9. Set environment variables
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

# 10. Switch to the created user
USER $USERNAME

# 11. Default command to run your script
CMD ["bash"]


##### Notes: #####
### How to start new docker:
# docker build -t image_name .
# docker run -dit --name container_name --gpus all -v ~/neurotrack:/app -w /app image_name

### Enter the container: 
# docker exec -it container_name bash
# then you will see - root@containerid:/app$

### Use tmux:
# tmux new -s training
# python test.py
# to detach the session (keep it running) - Ctrl + b, then d
# to reattach later: tmux attach -t training