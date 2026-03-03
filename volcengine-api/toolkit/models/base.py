from enum import Enum
from pydantic import BaseModel

class TaskStatus(Enum):
    QUEUED = "QUEUED"
    RUNNING = "RUNNING"
    SUCCEEDED = "SUCCEEDED"
    FAILED = "FAILED"
    CANCELLED = "CANCELLED"

class TaskType(Enum):
    IMAGE_GENERATION = "IMAGE_GENERATION"
    IMAGE_EDIT = "IMAGE_EDIT"
    VIDEO_T2V = "VIDEO_T2V"
    VIDEO_I2V = "VIDEO_I2V"
    VIDEO_FRAMES = "VIDEO_FRAMES"
    VIDEO_REFERENCES = "VIDEO_REFERENCES"
    AUDIO_TTS = "AUDIO_TTS"
    VISION_DETECTION = "VISION_DETECTION"

class BaseModelConfig(BaseModel):
    class Config:
        use_enum_values = True
