import sys
import pathlib

BASE_DIR = pathlib.Path(__file__).resolve().parents[2]  # .../volcengine-api
VOLCENGINE_PATH = BASE_DIR
if str(VOLCENGINE_PATH) not in sys.path:
    sys.path.insert(0, str(VOLCENGINE_PATH))

from toolkit.models.base import TaskStatus, TaskType, BaseModelConfig
try:
    from pydantic import BaseModel
except Exception:
    raise SystemExit("Pydantic is required for tests")

class SampleModel(BaseModelConfig):
    status: TaskStatus
    type: TaskType

def test_enums_have_expected_values():
    assert TaskStatus.QUEUED.value == "QUEUED"
    assert TaskStatus.RUNNING.value == "RUNNING"
    assert TaskStatus.SUCCEEDED.value == "SUCCEEDED"
    assert TaskStatus.FAILED.value == "FAILED"
    assert TaskStatus.CANCELLED.value == "CANCELLED"

    assert TaskType.IMAGE_GENERATION.value == "IMAGE_GENERATION"
    assert TaskType.IMAGE_EDIT.value == "IMAGE_EDIT"
    assert TaskType.VIDEO_T2V.value == "VIDEO_T2V"
    assert TaskType.VIDEO_I2V.value == "VIDEO_I2V"
    assert TaskType.VIDEO_FRAMES.value == "VIDEO_FRAMES"
    assert TaskType.VIDEO_REFERENCES.value == "VIDEO_REFERENCES"
    assert TaskType.AUDIO_TTS.value == "AUDIO_TTS"
    assert TaskType.VISION_DETECTION.value == "VISION_DETECTION"

def test_model_uses_enum_values_for_serialization_and_reconstruction():
    m = SampleModel(status=TaskStatus.QUEUED, type=TaskType.IMAGE_GENERATION)
    # With use_enum_values, the fields should serialize to their string values
    assert m.status == "QUEUED"
    assert m.type == "IMAGE_GENERATION"
    # Reconstruction from dict with string values should work
    m2 = SampleModel.model_validate({"status": "RUNNING", "type": "VIDEO_T2V"})
    assert m2.status == "RUNNING"
    assert m2.type == "VIDEO_T2V"
