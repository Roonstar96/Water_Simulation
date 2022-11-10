using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;


[RequireComponent(typeof(MeshFilter), typeof(MeshRenderer))]

public class GridMeshScript : MonoBehaviour
{

    Vector3[] vertices;
    int[] polies;

    Mesh mesh;

    //Mesh vars; cell size, dimensions,
    [SerializeField] public float cellSize = 1f;
    [SerializeField] public int meshSizeX = 100;
    [SerializeField] public int meshSizeZ = 100;

    void OnValidate()
    {
        mesh = GetComponent<MeshFilter>().sharedMesh;
        makeGrid();
        UpdateMesh();
    }

    void makeGrid()
    {
        //arrays eaqual to the size of the desired grid
        vertices = new Vector3[(meshSizeX + 1) * (meshSizeZ + 1)];
        //polies = new int[meshSizeX * meshSizeZ * 9];
        polies = new int[meshSizeX * meshSizeZ * 6];

        int ver = 0;
        int tri = 0;

        // iterates to produce a grid or vertices
        for (int x = 0; x <= meshSizeX; x++)
        {
            for (int z = 0; z <= meshSizeZ; z++)
            {
                // adds to vertex & poly arrays each itteration
                vertices[ver] = new Vector3((x * cellSize), 0, (z * cellSize));
                ver++;
            }
        }
        ver = 0;

        // itterates trough the grig to set the triangles
        for (int x = 0; x < meshSizeX; x++)
        {
            for (int z = 0; z < meshSizeZ; z++)
            {
                polies[tri] = ver;                                  // (0, 0)
                polies[tri + 1] = ver + 1;                          // (0, 1)
                polies[tri + 2] = ver + (meshSizeZ + 1);            // (1, 0)
                polies[tri + 3] = ver + (meshSizeZ + 1);            // (1, 0)
                polies[tri + 4] = ver + 1;                          // (0, 1)
                polies[tri + 5] = ver + (meshSizeZ + 1) + 1;        // (1, 1)
                //polies[tri + 6] = ver + (meshSizeZ + 1) + 1;        // (1, 1)
                //polies[tri + 7] = ver;                              // (0, 0)
                //polies[tri + 8] = ver + 1;                          // (0, 1)

                ver++;
                //tri += 9;
                tri += 6;
            }
            ver++;
        }
    }

    //add more verticies per quad

    /*void makeSuperGrid()
     {
         //arrays eaqual to the size of the desired grid
         vertices = new Vector3[(meshSizeX + 1) * (meshSizeZ + 1)];
         polies = new int[meshSizeX * meshSizeZ * 24];

         int ver = 0;
         int tri = 0;

         // centers everything with the origin 
         float vertexOffset = cellSize * 0.5f;

         // iterates to produce a grid or vertices
         for (int x = 0; x <= meshSizeX; x++)
         {
             for (int z = 0; z <= meshSizeZ; z++)
             {
                 //offsets the position of each quad in the grid, SO that a grid can form
                 //Vector3 cellOffset = new Vector3(x * cellSize, 0, z * cellSize);

                 // adds to vertex & poly arrays each itteration
                 vertices[ver] = new Vector3(((x * cellSize) + 1) - vertexOffset, 0, ((z * cellSize) + 1) - vertexOffset);
                 ver ++;
             }
         }
         ver = 0;

         // itterates trough the grig to set the triangles
         for (int x = 0; x < meshSizeX; x++)
         {
             for (int z = 0; z < meshSizeZ; z++)
             {
                 polies[tri     ] = ver;                              //(0, 0)
                 polies[tri +  1] = ver + 1;                      //(0, 1)
                 polies[tri +  2] = ver + (meshSizeZ + 1);        //(1, 1)

                 polies[tri +  3] = ver + (meshSizeZ + 1);        //(1, 1);
                 polies[tri +  4] = ver + 1;                      //(0, 1)
                 polies[tri +  5] = ver + 2;                      //(0, 2)

                 polies[tri +  6] = ver + 2;                      //(0, 2)
                 polies[tri +  7] = ver + (meshSizeZ + 1);        //(1, 1)
                 polies[tri +  8] = ver + (meshSizeZ + 1) + 2;    //(1, 2)

                 polies[tri +  9] = ver + (meshSizeZ + 1) + 2;    //(1, 2)
                 polies[tri + 10] = ver + (meshSizeZ + 1);       //(1, 1)
                 polies[tri + 11] = ver + (meshSizeZ + 2) + 2;   //(2, 2)

                 polies[tri + 12] = ver + (meshSizeZ + 2) + 2;   //(2, 2)
                 polies[tri + 13] = ver + (meshSizeZ + 2) + 1;   //(2, 1)
                 polies[tri + 14] = ver + (meshSizeZ + 1);       //(1, 1)

                 polies[tri + 15] = ver + (meshSizeZ + 1);       //(1, 1)
                 polies[tri + 16] = ver + (meshSizeZ + 1) + 2;   //(1, 2)
                 polies[tri + 17] = ver + (meshSizeZ + 2);       //(2, 0)

                 polies[tri + 18] = ver + (meshSizeZ + 2);       //(2, 0)
                 polies[tri + 19] = ver + (meshSizeZ + 1);       //(1, 1)
                 polies[tri + 20] = ver + (meshSizeZ);           //(1, 0)

                 polies[tri + 21] = ver + (meshSizeZ);           //(1, 0)
                 polies[tri + 22] = ver + (meshSizeZ + 1);       //(1, 1)
                 polies[tri + 23] = ver;                         //(0, 0)

                 ver += 2;
                 tri += 24;
             }
             ver += 1;
         }

     }*/

    void UpdateMesh()
    {
        mesh.Clear();

        mesh.vertices = vertices;
        mesh.triangles = polies;
        mesh.RecalculateNormals();
    }
}
