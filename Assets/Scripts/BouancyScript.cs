using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[RequireComponent(typeof(Rigidbody))]

public class BouancyScript : MonoBehaviour
{

    public Transform[] floaters;

    public float underWaterDrag = 3f;
    public float underWaterAngularDrag = 1f;
    public float airDrag = 0f;
    public float airAngularDrag = 0.05f;
    public float buoyancy = 15f;
    public float waterDepth = 0f;

    bool underwater;

    int floatersUnderWater;

    Rigidbody rigid;

    void Start()
    {
        rigid = GetComponent<Rigidbody>();
    }

    // Update is called once per frame
    void FixedUpdate()
    {
        floatersUnderWater = 0;

        for (int i = 0; i < floaters.Length; i ++)
        {
            float diff = floaters[i].position.y - waterDepth;

            // if underwater, push object up to surface
            if (diff < 0)
            {
                rigid.AddForceAtPosition(Vector3.up * buoyancy * Mathf.Abs(diff), floaters[i].position, ForceMode.Force);

                floatersUnderWater += 1;

                if (!underwater)
                {
                    underwater = true;
                    SwitchState(true);
                }
            }
        }

        if (underwater && floatersUnderWater == 0)
        {
            underwater = false;
            SwitchState(false);
        }
    }

    void SwitchState(bool isUnderwater)
    {
        if (isUnderwater)
        {        
            rigid.drag = underWaterDrag;
            rigid.angularDrag = underWaterAngularDrag;
        }
        else
        {
            rigid.drag = airDrag;
            rigid.angularDrag = airAngularDrag;
        }
    }
}
