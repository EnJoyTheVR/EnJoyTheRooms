using UnityEngine;
using DG.Tweening;

public class CameraDirector : MonoBehaviour
{
    public enum CameraMode { FreeFly, Follow, Animating }

    [Header("General")]
    public CameraMode mode = CameraMode.FreeFly;

    [Header("Free fly settings")]
    public float flySpeed = 5f;
    public float lookSensitivity = 2f;
    public bool smoothFly = true; // вкл/выкл плавность движения
    public float flyAccel = 5f;   // скорость разгона/торможения

    [Header("Follow mode")]
    public Transform followTarget;
    public float smoothFollow = 5f;
    public bool stabilization = true;   // Вкл/выкл стабилизацию
    public Vector3 followOffset = Vector3.zero; // Смещение камеры

    private Vector3 velocity = Vector3.zero;
    private Vector3 currentFlyVelocity = Vector3.zero; // для плавного FreeFly

    void Start()
    {
        Cursor.lockState = CursorLockMode.Locked;
        Cursor.visible = false;
    }

    void Update()
    {
        // --- Переключение режимов ---
        if (Input.GetKeyDown(KeyCode.F1)) mode = CameraMode.FreeFly;
        if (Input.GetKeyDown(KeyCode.F2)) mode = CameraMode.Follow;
        if (Input.GetKeyDown(KeyCode.F3)) mode = CameraMode.Animating;

        // --- Вкл/выкл стабилизацию ---
        if (Input.GetKeyDown(KeyCode.Tab)) stabilization = !stabilization;

        // --- Вкл/выкл сглаживание полёта ---
        if (Input.GetKeyDown(KeyCode.CapsLock)) smoothFly = !smoothFly;

        // --- Управление смещением в Follow ---
        if (mode == CameraMode.Follow)
        {
            if (Input.GetKey(KeyCode.I)) followOffset += Vector3.forward * 0.01f;
            if (Input.GetKey(KeyCode.K)) followOffset += Vector3.back * 0.01f;
            if (Input.GetKey(KeyCode.J)) followOffset += Vector3.left * 0.01f;
            if (Input.GetKey(KeyCode.L)) followOffset += Vector3.right * 0.01f;
            if (Input.GetKey(KeyCode.U)) followOffset += Vector3.up * 0.01f;
            if (Input.GetKey(KeyCode.O)) followOffset += Vector3.down * 0.01f;
        }

        // --- Обработка режимов ---
        switch (mode)
        {
            case CameraMode.FreeFly:
                HandleFreeFly();
                break;
            case CameraMode.Follow:
                HandleFollow();
                break;
            case CameraMode.Animating:
                HandleAnimations();
                break;
        }
    }

    // -------- FREE FLY --------
    private void HandleFreeFly()
    {
        float h = Input.GetAxisRaw("Horizontal");
        float v = Input.GetAxisRaw("Vertical");
        float upDown = 0f;

        if (Input.GetKey(KeyCode.E)) upDown = 1f;
        if (Input.GetKey(KeyCode.Q)) upDown = -1f;

        Vector3 targetMove = new Vector3(h, upDown, v).normalized * flySpeed;

        if (smoothFly)
        {
            // Плавное ускорение и торможение
            currentFlyVelocity = Vector3.Lerp(currentFlyVelocity, targetMove, Time.deltaTime * flyAccel);
            transform.Translate(currentFlyVelocity * Time.deltaTime, Space.Self);
        }
        else
        {
            transform.Translate(targetMove * Time.deltaTime, Space.Self);
        }

        // Поворот мышью
        float mouseX = Input.GetAxis("Mouse X") * lookSensitivity;
        float mouseY = -Input.GetAxis("Mouse Y") * lookSensitivity;
        transform.Rotate(mouseY, mouseX, 0, Space.Self);
    }

    // -------- FOLLOW --------
    private void HandleFollow()
    {
        if (followTarget == null) return;

        Vector3 targetPos = followTarget.position + followTarget.TransformDirection(followOffset);

        if (stabilization)
        {
            transform.position = Vector3.SmoothDamp(
                transform.position,
                targetPos,
                ref velocity,
                1f / smoothFollow
            );
            transform.rotation = Quaternion.Slerp(
                transform.rotation,
                followTarget.rotation,
                Time.deltaTime * smoothFollow
            );
        }
        else
        {
            transform.position = targetPos;
            transform.rotation = followTarget.rotation;
        }
    }

    // -------- ANIMATIONS --------
    private void HandleAnimations()
    {
        if (Input.GetKeyDown(KeyCode.Alpha1))
            transform.DOLocalMoveZ(-2f, 1f).SetRelative().SetEase(Ease.InOutSine);

        if (Input.GetKeyDown(KeyCode.Alpha2))
            transform.DOLocalMoveZ(2f, 1f).SetRelative().SetEase(Ease.InOutSine);

        if (Input.GetKeyDown(KeyCode.Alpha3))
            transform.DOLocalRotate(new Vector3(0, 360, 0), 2f, RotateMode.LocalAxisAdd)
                     .SetEase(Ease.InOutSine);

        if (Input.GetKeyDown(KeyCode.Alpha4))
            transform.DOLocalMoveX(1.5f, 1f).SetRelative().SetEase(Ease.OutQuad);

        if (Input.GetKeyDown(KeyCode.Alpha5))
            transform.DOLocalRotate(new Vector3(15, 0, 0), 1f, RotateMode.LocalAxisAdd)
                     .SetEase(Ease.OutSine);

        if (Input.GetKeyDown(KeyCode.Alpha6))
        {
            Sequence seq = DOTween.Sequence();
            seq.Append(transform.DOLocalRotate(new Vector3(0, 90, 0), 0.7f, RotateMode.LocalAxisAdd)
                       .SetEase(Ease.InSine));
            seq.Append(transform.DOLocalRotate(new Vector3(0, 90, 0), 0.7f, RotateMode.LocalAxisAdd)
                       .SetEase(Ease.OutSine));
        }
    }
}
