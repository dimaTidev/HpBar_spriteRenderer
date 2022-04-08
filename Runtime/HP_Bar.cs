using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[RequireComponent (typeof(SpriteRenderer))]
public class HP_Bar : MonoBehaviour
{
    [SerializeField] bool isHide;
    [SerializeField] Color colorSecond;                     //цвет фона который остается при изменении - targetFillHiden
    [SerializeField] Color colorFon;                     //цвет фона который остается при изменении - targetFillHiden
    [SerializeField] float speedFill = 2;                   //скорость изменения значения - curFill

    [SerializeField, Range(0, 1)] float curFill = 0;        //значение которое ползет в самом конце
    [SerializeField, Range(0, 1)] float targetFill = 0;     //значение к кторому будет двигаться - targetFillHiden
  //  float targetFillHiden;                                  //Текущее значение которое видит игрок
    float timer;
    float timerToFill = 1;                                  //таймер через который значение - curFill - начнет двигаться
    float timerToDisable = 2;                               //такймер из-за которого выключится объект после того как сравняются значения - curFill == targetFill
    Material mat;

    

    [SerializeField, HideInInspector] Shader shaderFill;
    string materialkeyXCorrectStart = "_XCorrectStart";
    string materialkeyXCorrectEnd = "_XCorrectEnd";
    string materialkey_TargetFill = "_FillTarget";
    string materialkey_CurFill = "_Fill";
    string materialkey_ColorSecond = "_ColorSecond";
    string materialkey_ColorFon = "_ColorFon";

    SpriteRenderer sprRend;


    [SerializeField] ActionEvent_Subscribe subscribe;


    void Start()
    {
        subscribe.Invoke();

        sprRend = GetComponent<SpriteRenderer>();
        if(shaderFill){
            mat = new Material(shaderFill);
            sprRend.sharedMaterial = mat;
            if(sprRend.sprite)
            {
                Sprite sprite = sprRend.sprite;
                float width = sprite.texture.width;
                mat.SetFloat(materialkeyXCorrectStart, -Mathf.InverseLerp(0, width, sprite.rect.x));
                mat.SetFloat(materialkeyXCorrectEnd, Mathf.InverseLerp(0, width, sprite.rect.width));
                mat.SetColor(materialkey_ColorSecond, colorSecond);
                mat.SetColor(materialkey_ColorFon, colorFon);
            }
        }
        else
        {
            if (!shaderFill)
                print("No Selected Shader in " + gameObject.name);
        }
        Reset();
    }

    float CurFill
    {
        set
        {
            curFill = value;
            if(mat)
                mat.SetFloat(materialkey_CurFill, value);
        }
    }
    float TargetFill
    {
        set
        {
            targetFill = value;
            if (mat)
                mat.SetFloat(materialkey_TargetFill, value);
        }
    }

    void Update()
    {
      /*  if(targetFillHiden != targetFill)
        {
            TargetFill = Mathf.MoveTowards(TargetFill, targetFill, Time.deltaTime * speedFill * 0.1f);
        }else
        {*/
        if(curFill != targetFill)
        {
            if(timer >= timerToFill){
                CurFill = Mathf.MoveTowards(curFill, targetFill, Time.deltaTime * speedFill);
            }else
                timer += Time.deltaTime;
        }
        else
        {
            if(isHide)
            {
                timer += Time.deltaTime;
                if (timer >= timerToDisable)
                {
                    gameObject.SetActive(false);
                } 
            }
        }
    //    }
    }

    /// <param name="value">Range(0,1)</param>
    public void SetValue(float value)
    {
        Debug.Log("Take value = " + value);
        gameObject.SetActive(true);
        //Debug.Log("take value" + value);
        if (value <= 0)
        {
            Reset();
            return;
        }
        TargetFill = value;
        timer = 0;
    }

  /*  [ContextMenu("Minus 20")]
    void SetTest()
    {
        SetValue(targetFill - 0.2f);
    }*/

    public void Reset()
    {
        timer = 0;
        CurFill = 1;
        targetFill = 1;
        //  targetFillHiden = 1;
        if (isHide)
            gameObject.SetActive(false);
    }

#if UNITY_EDITOR
    void OnValidate()
    {

        if (Application.isPlaying) return;
        sprRend = GetComponent<SpriteRenderer>();
        if (sprRend)
        {
            mat = sprRend.sharedMaterial;
            if (mat && sprRend.sprite)
            {
                Sprite sprite = sprRend.sprite;
                float width = sprite.texture.width;
                mat.SetFloat(materialkeyXCorrectStart, -Mathf.InverseLerp(0, width, sprite.rect.x));
                mat.SetFloat(materialkeyXCorrectEnd, Mathf.InverseLerp(0, width, sprite.rect.width));
                mat.SetColor(materialkey_ColorSecond, colorSecond);
                mat.SetColor(materialkey_ColorFon, colorFon);

                CurFill = curFill;
                TargetFill = targetFill;
            }
        }
    }
#endif
}
