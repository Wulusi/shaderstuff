using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class AutoRotate : MonoBehaviour
{
    [SerializeField]
    private GameObject rotateTarget;

    [SerializeField]
    [Range(0,10)]
    private float rotatingSpd;

    [SerializeField]
    private bool rotationX, rotationY;
    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        RotateObject();
    }

    void RotateObject()
    {
        if (rotateTarget != null) 
        {
            if (rotationX)
            {
                rotateTarget.transform.Rotate(rotatingSpd * Time.deltaTime, 0 ,0, Space.Self);
            }

            if (rotationY)
            {
                rotateTarget.transform.Rotate(0, rotatingSpd * Time.deltaTime, 0, Space.Self);
            }

        }
    }
}
