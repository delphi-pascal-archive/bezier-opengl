Courbes de bezier et motion blur--------------------------------
Url     : http://codes-sources.commentcamarche.net/source/24601-courbes-de-bezier-et-motion-blurAuteur  : cs_frostieDate    : 02/08/2013
Licence :
=========

Ce document intitulé « Courbes de bezier et motion blur » issu de CommentCaMarche
(codes-sources.commentcamarche.net) est mis à disposition sous les termes de
la licence Creative Commons. Vous pouvez copier, modifier des copies de cette
source, dans les conditions fixées par la licence, tant que cette note
apparaît clairement.

Description :
=============

Le code est juste un exemple d'utilisation de courbes de bezier avec opengl. J'a
i aussi mis du motion blur grace a une petite astuce : supprimer les appels a gl
ClearColor ce qui a pour effet de redessiner a chaque fois la nouvelle scene par
 dessus l'ancienne. Le truc : on dessine un carre en mode 2D qui recouvre l'ense
mble de la surface de l'ecran en arriere plan et en transparence. Selon l'intens
ite de la transparence que vous applique vous allez 'efface' le buffer des coule
urs plus ou moins vite ce qui va creer un effet semblable a la persitence retien
ne. C'est classique mais simple : donc a savoir ;)
<br /><a name='source-exempl
e'></a><h2> Source / Exemple : </h2>
<br /><pre class='code' data-mode='basic'
>
dans le zip
</pre>
<br /><a name='conclusion'></a><h2> Conclusion : </h2>

<br />Une petite interface permet de regler le nombres d'elements de la fontain
e de particule ainsi que l,intensite de la transparence du carre sur le bord sup
erieur et sur le bord inferieur.
<br />le zip contient aussi le code pour creer
 des mesh en opengl (meme principe que les courbes de bezier mais applique a une
 surface). Pour compiler cette partie, decommentez dans la unit GFX 'Bezier:=TBe
zier.create(...' dans la procedure glInit et 'Bezier.render' dans la procedure g
lDraw.
<br />
<br />Je me suis appuye sur les tutos du toujours excelent www.s
ulaco.co.za pour ce qui des references opengl sur les courbes de bezier.
