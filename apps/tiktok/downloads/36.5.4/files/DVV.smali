.class public final LX/DVV;
.super Ljava/lang/Object;
.source "SourceFile"


# static fields
.field public static final LIZ:[Ljava/lang/String;

.field public static final LIZIZ:[Ljava/lang/String;

.field public static final LIZJ:[Ljava/lang/String;

.field public static final LIZLLL:[Ljava/lang/String;


# direct methods
.method public static constructor <clinit>()V
    .locals 14

    .prologue
    .line 0
    const-string v0, "_id"

    .line 1
    .line 2
    const-string v1, "_display_name"

    .line 3
    .line 4
    const-string v2, "date_modified"

    .line 5
    .line 6
    const-string v3, "date_added"

    .line 7
    .line 8
    const-string v4, "mime_type"

    .line 9
    .line 10
    const-string v5, "_size"

    .line 11
    .line 12
    const-string/jumbo v6, "width"

    .line 13
    .line 14
    .line 15
    const-string v7, "height"

    .line 16
    .line 17
    const-string v8, "relative_path"

    .line 18
    .line 19
    const-string v9, "_data"

    .line 20
    .line 21
    const-string v10, "datetaken"

    .line 22
    .line 23
    const-string v11, "orientation"

    .line 24
    .line 25
    filled-new-array/range {v0 .. v11}, [Ljava/lang/String;

    .line 26
    .line 27
    .line 28
    move-result-object v0

    .line 29
    sput-object v0, LX/DVV;->LIZ:[Ljava/lang/String;

    .line 30
    .line 31
    const-string v0, "_id"

    .line 32
    .line 33
    const-string v1, "_display_name"

    .line 34
    .line 35
    const-string v2, "date_modified"

    .line 36
    .line 37
    const-string v3, "date_added"

    .line 38
    .line 39
    const-string v4, "mime_type"

    .line 40
    .line 41
    const-string v5, "_size"

    .line 42
    .line 43
    const-string/jumbo v6, "width"

    .line 44
    .line 45
    .line 46
    const-string v7, "height"

    .line 47
    .line 48
    const-string v8, "_data"

    .line 49
    .line 50
    const-string v9, "datetaken"

    .line 51
    .line 52
    const-string v10, "orientation"

    .line 53
    .line 54
    filled-new-array/range {v0 .. v10}, [Ljava/lang/String;

    .line 55
    .line 56
    .line 57
    move-result-object v0

    .line 58
    sput-object v0, LX/DVV;->LIZIZ:[Ljava/lang/String;

    .line 59
    .line 60
    const-string v0, "_id"

    .line 61
    .line 62
    const-string v1, "_display_name"

    .line 63
    .line 64
    const-string v2, "date_modified"

    .line 65
    .line 66
    const-string v3, "date_added"

    .line 67
    .line 68
    const-string v4, "mime_type"

    .line 69
    .line 70
    const-string v5, "duration"

    .line 71
    .line 72
    const-string v6, "_size"

    .line 73
    .line 74
    const-string/jumbo v7, "width"

    .line 75
    .line 76
    .line 77
    const-string v8, "height"

    .line 78
    .line 79
    const-string v9, "relative_path"

    .line 80
    .line 81
    const-string v10, "_data"

    .line 82
    .line 83
    const-string v11, "datetaken"

    .line 84
    .line 85
    const-string v12, "resolution"

    .line 86
    .line 87
    const-string v13, "orientation"

    .line 88
    .line 89
    filled-new-array/range {v0 .. v13}, [Ljava/lang/String;

    .line 90
    .line 91
    .line 92
    move-result-object v0

    .line 93
    sput-object v0, LX/DVV;->LIZJ:[Ljava/lang/String;

    .line 94
    .line 95
    const-string v0, "_id"

    .line 96
    .line 97
    const-string v1, "_display_name"

    .line 98
    .line 99
    const-string v2, "date_modified"

    .line 100
    .line 101
    const-string v3, "date_added"

    .line 102
    .line 103
    const-string v4, "mime_type"

    .line 104
    .line 105
    const-string v5, "duration"

    .line 106
    .line 107
    const-string v6, "_size"

    .line 108
    .line 109
    const-string/jumbo v7, "width"

    .line 110
    .line 111
    .line 112
    const-string v8, "height"

    .line 113
    .line 114
    const-string v9, "_data"

    .line 115
    .line 116
    const-string v10, "datetaken"

    .line 117
    .line 118
    const-string v11, "resolution"

    .line 119
    .line 120
    filled-new-array/range {v0 .. v11}, [Ljava/lang/String;

    .line 121
    .line 122
    .line 123
    move-result-object v0

    .line 124
    sput-object v0, LX/DVV;->LIZLLL:[Ljava/lang/String;

    .line 125
    .line 126
    const/4 v0, 0x1

    .line 127
    invoke-static {v0}, Ljava/lang/String;->valueOf(I)Ljava/lang/String;

    .line 128
    .line 129
    .line 130
    const/4 v0, 0x3

    .line 131
    invoke-static {v0}, Ljava/lang/String;->valueOf(I)Ljava/lang/String;

    .line 132
    .line 133
    .line 134
    return-void
.end method

.method public static LIZ(Landroid/content/Context;Ljava/lang/String;)Landroid/net/Uri;
    .locals 1

    .prologue
    .line 33554432
    const-string v0, "image/jpeg"

    .line 33554433
    .line 33554434
    invoke-static {p0, p1, v0}, LX/DVV;->LIZIZ(Landroid/content/Context;Ljava/lang/String;Ljava/lang/String;)Landroid/net/Uri;

    .line 33554435
    .line 33554436
    .line 33554437
    move-result-object v0

    .line 33554438
    return-object v0
.end method

.method public static LIZIZ(Landroid/content/Context;Ljava/lang/String;Ljava/lang/String;)Landroid/net/Uri;
    .locals 3

    .prologue
    .line 50331648
    new-instance v2, Ljava/io/File;

    .line 50331649
    .line 50331650
    invoke-static {}, LX/CLD;->LIZ()Ljava/lang/StringBuilder;

    .line 50331651
    .line 50331652
    .line 50331653
    move-result-object v1

    .line 50331654
    invoke-static {}, LX/bFn;->H()Ljava/io/File;

    .line 50331655
    .line 50331656
    .line 50331657
    move-result-object v0

    .line 50331658
    invoke-virtual {v0}, Ljava/io/File;->getPath()Ljava/lang/String;

    .line 50331659
    .line 50331660
    .line 50331661
    move-result-object v0

    .line 50331662
    invoke-virtual {v1, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    .line 50331663
    .line 50331664
    .line 50331665
    const-string v0, "/"

    .line 50331666
    .line 50331667
    invoke-virtual {v1, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    .line 50331668
    .line 50331669
    .line 50331670
    sget-object v0, Landroid/os/Environment;->DIRECTORY_DCIM:Ljava/lang/String;

    .line 50331671
    .line 50331672
    invoke-virtual {v1, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    .line 50331673
    .line 50331674
    .line 50331675
    const-string v0, "/Camera"

    .line 50331676
    .line 50331677
    invoke-virtual {v1, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    .line 50331678
    .line 50331679
    .line 50331680
    invoke-static {v1}, LX/CLD;->LIZIZ(Ljava/lang/StringBuilder;)Ljava/lang/String;

    .line 50331681
    .line 50331682
    .line 50331683
    move-result-object v0

    .line 50331684
    invoke-direct {v2, v0}, Ljava/io/File;-><init>(Ljava/lang/String;)V

    .line 50331685
    .line 50331686
    .line 50331687
    invoke-virtual {v2}, Ljava/io/File;->exists()Z

    .line 50331688
    .line 50331689
    .line 50331690
    move-result v0

    .line 50331691
    if-nez v0, :cond_0

    .line 50331692
    .line 50331693
    invoke-virtual {v2}, Ljava/io/File;->mkdirs()Z

    .line 50331694
    .line 50331695
    .line 50331696
    :cond_0
    invoke-static {}, LX/CLD;->LIZ()Ljava/lang/StringBuilder;

    .line 50331697
    .line 50331698
    .line 50331699
    move-result-object v1

    .line 50331700
    sget-object v0, Landroid/os/Environment;->DIRECTORY_DCIM:Ljava/lang/String;

    .line 50331701
    .line 50331702
    invoke-virtual {v1, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    .line 50331703
    .line 50331704
    .line 50331705
    const-string v0, "/Camera/"

    .line 50331706
    .line 50331707
    invoke-virtual {v1, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    .line 50331708
    .line 50331709
    .line 50331710
    invoke-static {v1}, LX/CLD;->LIZIZ(Ljava/lang/StringBuilder;)Ljava/lang/String;

    .line 50331711
    .line 50331712
    .line 50331713
    move-result-object v0

    .line 50331714
    invoke-static {p0, p1, p2, v0}, LX/DVV;->LIZJ(Landroid/content/Context;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)Landroid/net/Uri;

    .line 50331715
    .line 50331716
    .line 50331717
    move-result-object v0

    .line 50331718
    return-object v0
.end method

.method public static LIZJ(Landroid/content/Context;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)Landroid/net/Uri;
    .locals 5

    .prologue
    .line 67108864
    if-eqz p0, :cond_2

    .line 67108865
    .line 67108866
    invoke-static {p1}, Landroid/text/TextUtils;->isEmpty(Ljava/lang/CharSequence;)Z

    .line 67108867
    .line 67108868
    .line 67108869
    move-result v0

    .line 67108870
    if-nez v0, :cond_2

    .line 67108871
    .line 67108872
    invoke-static {p3}, Landroid/text/TextUtils;->isEmpty(Ljava/lang/CharSequence;)Z

    .line 67108873
    .line 67108874
    .line 67108875
    move-result v0

    .line 67108876
    if-nez v0, :cond_2

    .line 67108877
    .line 67108878
    const-string v4, "/"

    .line 67108879
    .line 67108880
    invoke-virtual {p3, v4}, Ljava/lang/String;->endsWith(Ljava/lang/String;)Z

    .line 67108881
    .line 67108882
    .line 67108883
    move-result v0

    .line 67108884
    if-nez v0, :cond_0

    .line 67108885
    .line 67108886
    invoke-static {}, LX/CLD;->LIZ()Ljava/lang/StringBuilder;

    .line 67108887
    .line 67108888
    .line 67108889
    move-result-object v0

    .line 67108890
    invoke-virtual {v0, p3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    .line 67108891
    .line 67108892
    .line 67108893
    invoke-virtual {v0, v4}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    .line 67108894
    .line 67108895
    .line 67108896
    invoke-static {v0}, LX/CLD;->LIZIZ(Ljava/lang/StringBuilder;)Ljava/lang/String;

    .line 67108897
    .line 67108898
    .line 67108899
    move-result-object p3

    .line 67108900
    :cond_0
    new-instance v3, Landroid/content/ContentValues;

    .line 67108901
    .line 67108902
    invoke-direct {v3}, Landroid/content/ContentValues;-><init>()V

    .line 67108903
    .line 67108904
    .line 67108905
    const-string v0, "_display_name"

    .line 67108906
    .line 67108907
    invoke-virtual {v3, v0, p1}, Landroid/content/ContentValues;->put(Ljava/lang/String;Ljava/lang/String;)V

    .line 67108908
    .line 67108909
    .line 67108910
    invoke-static {}, Ljava/lang/System;->currentTimeMillis()J

    .line 67108911
    .line 67108912
    .line 67108913
    move-result-wide v0

    .line 67108914
    invoke-static {v0, v1}, Ljava/lang/Long;->valueOf(J)Ljava/lang/Long;

    .line 67108915
    .line 67108916
    .line 67108917
    move-result-object v1

    .line 67108918
    const-string v0, "datetaken"

    .line 67108919
    .line 67108920
    invoke-virtual {v3, v0, v1}, Landroid/content/ContentValues;->put(Ljava/lang/String;Ljava/lang/Long;)V

    .line 67108921
    .line 67108922
    .line 67108923
    const-string v0, "mime_type"

    .line 67108924
    .line 67108925
    invoke-virtual {v3, v0, p2}, Landroid/content/ContentValues;->put(Ljava/lang/String;Ljava/lang/String;)V

    .line 67108926
    .line 67108927
    .line 67108928
    invoke-static {}, LX/DTv;->LIZLLL()Z

    .line 67108929
    .line 67108930
    .line 67108931
    move-result v0

    .line 67108932
    if-eqz v0, :cond_1

    .line 67108933
    .line 67108934
    const-string v0, "external_primary"

    .line 67108935
    .line 67108936
    invoke-static {v0}, Landroid/provider/MediaStore$Images$Media;->getContentUri(Ljava/lang/String;)Landroid/net/Uri;

    .line 67108937
    .line 67108938
    .line 67108939
    move-result-object v2

    .line 67108940
    const-string v0, "relative_path"

    .line 67108941
    .line 67108942
    invoke-virtual {v3, v0, p3}, Landroid/content/ContentValues;->put(Ljava/lang/String;Ljava/lang/String;)V

    .line 67108943
    .line 67108944
    .line 67108945
    :goto_0
    invoke-virtual {p0}, Landroid/content/Context;->getContentResolver()Landroid/content/ContentResolver;

    .line 67108946
    .line 67108947
    .line 67108948
    move-result-object v0

    .line 67108949
    invoke-virtual {v0, v2, v3}, Landroid/content/ContentResolver;->insert(Landroid/net/Uri;Landroid/content/ContentValues;)Landroid/net/Uri;

    .line 67108950
    .line 67108951
    .line 67108952
    move-result-object v0

    .line 67108953
    return-object v0

    .line 67108954
    :cond_1
    sget-object v2, Landroid/provider/MediaStore$Images$Media;->EXTERNAL_CONTENT_URI:Landroid/net/Uri;

    .line 67108955
    .line 67108956
    invoke-static {}, LX/CLD;->LIZ()Ljava/lang/StringBuilder;

    .line 67108957
    .line 67108958
    .line 67108959
    move-result-object v1

    .line 67108960
    invoke-static {}, LX/bFn;->H()Ljava/io/File;

    .line 67108961
    .line 67108962
    .line 67108963
    move-result-object v0

    .line 67108964
    invoke-virtual {v0}, Ljava/io/File;->getPath()Ljava/lang/String;

    .line 67108965
    .line 67108966
    .line 67108967
    move-result-object v0

    .line 67108968
    invoke-virtual {v1, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    .line 67108969
    .line 67108970
    .line 67108971
    invoke-virtual {v1, v4}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    .line 67108972
    .line 67108973
    .line 67108974
    invoke-virtual {v1, p3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    .line 67108975
    .line 67108976
    .line 67108977
    invoke-virtual {v1, v4}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    .line 67108978
    .line 67108979
    .line 67108980
    invoke-virtual {v1, p1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    .line 67108981
    .line 67108982
    .line 67108983
    invoke-static {v1}, LX/CLD;->LIZIZ(Ljava/lang/StringBuilder;)Ljava/lang/String;

    .line 67108984
    .line 67108985
    .line 67108986
    move-result-object v0

    .line 67108987
    invoke-static {v0}, LX/DTv;->LJ(Ljava/lang/String;)Ljava/lang/String;

    .line 67108988
    .line 67108989
    .line 67108990
    move-result-object v1

    .line 67108991
    const-string v0, "_data"

    .line 67108992
    .line 67108993
    invoke-virtual {v3, v0, v1}, Landroid/content/ContentValues;->put(Ljava/lang/String;Ljava/lang/String;)V

    .line 67108994
    .line 67108995
    .line 67108996
    goto :goto_0

    .line 67108997
    :cond_2
    const/4 v0, 0x0

    .line 67108998
    return-object v0
.end method

.method public static LIZLLL(Landroid/content/Context;Ljava/lang/String;)Landroid/net/Uri;
    .locals 3

    .prologue
    .line 33554432
    new-instance v2, Ljava/io/File;

    .line 33554433
    .line 33554434
    invoke-static {}, LX/CLD;->LIZ()Ljava/lang/StringBuilder;

    .line 33554435
    .line 33554436
    .line 33554437
    move-result-object v1

    .line 33554438
    invoke-static {}, LX/bFn;->H()Ljava/io/File;

    .line 33554439
    .line 33554440
    .line 33554441
    move-result-object v0

    .line 33554442
    invoke-virtual {v0}, Ljava/io/File;->getPath()Ljava/lang/String;

    .line 33554443
    .line 33554444
    .line 33554445
    move-result-object v0

    .line 33554446
    invoke-virtual {v1, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    .line 33554447
    .line 33554448
    .line 33554449
    const-string v0, "/"

    .line 33554450
    .line 33554451
    invoke-virtual {v1, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    .line 33554452
    .line 33554453
    .line 33554454
    sget-object v0, Landroid/os/Environment;->DIRECTORY_MOVIES:Ljava/lang/String;

    .line 33554455
    .line 33554456
    invoke-virtual {v1, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    .line 33554457
    .line 33554458
    .line 33554459
    const-string v0, "/TikTok"

    .line 33554460
    .line 33554461
    invoke-virtual {v1, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    .line 33554462
    .line 33554463
    .line 33554464
    invoke-static {v1}, LX/CLD;->LIZIZ(Ljava/lang/StringBuilder;)Ljava/lang/String;

    .line 33554465
    .line 33554466
    .line 33554467
    move-result-object v0

    .line 33554468
    invoke-direct {v2, v0}, Ljava/io/File;-><init>(Ljava/lang/String;)V

    .line 33554469
    .line 33554470
    .line 33554471
    invoke-virtual {v2}, Ljava/io/File;->exists()Z

    .line 33554472
    .line 33554473
    .line 33554474
    move-result v0

    .line 33554475
    if-nez v0, :cond_0

    .line 33554476
    .line 33554477
    invoke-virtual {v2}, Ljava/io/File;->mkdirs()Z

    .line 33554478
    .line 33554479
    .line 33554480
    :cond_0
    invoke-static {}, LX/CLD;->LIZ()Ljava/lang/StringBuilder;

    .line 33554481
    .line 33554482
    .line 33554483
    move-result-object v1

    .line 33554484
    sget-object v0, Landroid/os/Environment;->DIRECTORY_MOVIES:Ljava/lang/String;

    .line 33554485
    .line 33554486
    invoke-virtual {v1, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    .line 33554487
    .line 33554488
    .line 33554489
    const-string v0, "/TikTok/"

    .line 33554490
    .line 33554491
    invoke-virtual {v1, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    .line 33554492
    .line 33554493
    .line 33554494
    invoke-static {v1}, LX/CLD;->LIZIZ(Ljava/lang/StringBuilder;)Ljava/lang/String;

    .line 33554495
    .line 33554496
    .line 33554497
    move-result-object v1

    .line 33554498
    const-string/jumbo v0, "video/mp4"

    .line 33554499
    .line 33554500
    .line 33554501
    invoke-static {p0, p1, v0, v1}, LX/DVV;->LJ(Landroid/content/Context;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)Landroid/net/Uri;

    .line 33554502
    .line 33554503
    .line 33554504
    move-result-object v0

    .line 33554505
    return-object v0
.end method

.method public static LJ(Landroid/content/Context;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)Landroid/net/Uri;
    .locals 5

    .prologue
    .line 67108864
    if-eqz p0, :cond_2

    .line 67108865
    .line 67108866
    invoke-static {p1}, Landroid/text/TextUtils;->isEmpty(Ljava/lang/CharSequence;)Z

    .line 67108867
    .line 67108868
    .line 67108869
    move-result v0

    .line 67108870
    if-nez v0, :cond_2

    .line 67108871
    .line 67108872
    invoke-static {p3}, Landroid/text/TextUtils;->isEmpty(Ljava/lang/CharSequence;)Z

    .line 67108873
    .line 67108874
    .line 67108875
    move-result v0

    .line 67108876
    if-nez v0, :cond_2

    .line 67108877
    .line 67108878
    const-string v4, "/"

    .line 67108879
    .line 67108880
    invoke-virtual {p3, v4}, Ljava/lang/String;->endsWith(Ljava/lang/String;)Z

    .line 67108881
    .line 67108882
    .line 67108883
    move-result v0

    .line 67108884
    if-nez v0, :cond_0

    .line 67108885
    .line 67108886
    invoke-static {}, LX/CLD;->LIZ()Ljava/lang/StringBuilder;

    .line 67108887
    .line 67108888
    .line 67108889
    move-result-object v0

    .line 67108890
    invoke-virtual {v0, p3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    .line 67108891
    .line 67108892
    .line 67108893
    invoke-virtual {v0, v4}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    .line 67108894
    .line 67108895
    .line 67108896
    invoke-static {v0}, LX/CLD;->LIZIZ(Ljava/lang/StringBuilder;)Ljava/lang/String;

    .line 67108897
    .line 67108898
    .line 67108899
    move-result-object p3

    .line 67108900
    :cond_0
    new-instance v3, Landroid/content/ContentValues;

    .line 67108901
    .line 67108902
    invoke-direct {v3}, Landroid/content/ContentValues;-><init>()V

    .line 67108903
    .line 67108904
    .line 67108905
    const-string v0, "_display_name"

    .line 67108906
    .line 67108907
    invoke-virtual {v3, v0, p1}, Landroid/content/ContentValues;->put(Ljava/lang/String;Ljava/lang/String;)V

    .line 67108908
    .line 67108909
    .line 67108910
    invoke-static {}, Ljava/lang/System;->currentTimeMillis()J

    .line 67108911
    .line 67108912
    .line 67108913
    move-result-wide v0

    .line 67108914
    invoke-static {v0, v1}, Ljava/lang/Long;->valueOf(J)Ljava/lang/Long;

    .line 67108915
    .line 67108916
    .line 67108917
    move-result-object v1

    .line 67108918
    const-string v0, "datetaken"

    .line 67108919
    .line 67108920
    invoke-virtual {v3, v0, v1}, Landroid/content/ContentValues;->put(Ljava/lang/String;Ljava/lang/Long;)V

    .line 67108921
    .line 67108922
    .line 67108923
    const-string v0, "mime_type"

    .line 67108924
    .line 67108925
    invoke-virtual {v3, v0, p2}, Landroid/content/ContentValues;->put(Ljava/lang/String;Ljava/lang/String;)V

    .line 67108926
    .line 67108927
    .line 67108928
    invoke-static {}, LX/DTv;->LIZLLL()Z

    .line 67108929
    .line 67108930
    .line 67108931
    move-result v0

    .line 67108932
    if-eqz v0, :cond_1

    .line 67108933
    .line 67108934
    const-string v0, "external_primary"

    .line 67108935
    .line 67108936
    invoke-static {v0}, Landroid/provider/MediaStore$Video$Media;->getContentUri(Ljava/lang/String;)Landroid/net/Uri;

    .line 67108937
    .line 67108938
    .line 67108939
    move-result-object v2

    .line 67108940
    const-string v0, "relative_path"

    .line 67108941
    .line 67108942
    invoke-virtual {v3, v0, p3}, Landroid/content/ContentValues;->put(Ljava/lang/String;Ljava/lang/String;)V

    .line 67108943
    .line 67108944
    .line 67108945
    :goto_0
    invoke-virtual {p0}, Landroid/content/Context;->getContentResolver()Landroid/content/ContentResolver;

    .line 67108946
    .line 67108947
    .line 67108948
    move-result-object v0

    .line 67108949
    invoke-virtual {v0, v2, v3}, Landroid/content/ContentResolver;->insert(Landroid/net/Uri;Landroid/content/ContentValues;)Landroid/net/Uri;

    .line 67108950
    .line 67108951
    .line 67108952
    move-result-object v0

    .line 67108953
    return-object v0

    .line 67108954
    :cond_1
    sget-object v2, Landroid/provider/MediaStore$Video$Media;->EXTERNAL_CONTENT_URI:Landroid/net/Uri;

    .line 67108955
    .line 67108956
    invoke-static {}, LX/CLD;->LIZ()Ljava/lang/StringBuilder;

    .line 67108957
    .line 67108958
    .line 67108959
    move-result-object v1

    .line 67108960
    invoke-static {}, LX/bFn;->H()Ljava/io/File;

    .line 67108961
    .line 67108962
    .line 67108963
    move-result-object v0

    .line 67108964
    invoke-virtual {v0}, Ljava/io/File;->getPath()Ljava/lang/String;

    .line 67108965
    .line 67108966
    .line 67108967
    move-result-object v0

    .line 67108968
    invoke-virtual {v1, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    .line 67108969
    .line 67108970
    .line 67108971
    invoke-virtual {v1, v4}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    .line 67108972
    .line 67108973
    .line 67108974
    invoke-virtual {v1, p3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    .line 67108975
    .line 67108976
    .line 67108977
    invoke-virtual {v1, v4}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    .line 67108978
    .line 67108979
    .line 67108980
    invoke-virtual {v1, p1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    .line 67108981
    .line 67108982
    .line 67108983
    invoke-static {v1}, LX/CLD;->LIZIZ(Ljava/lang/StringBuilder;)Ljava/lang/String;

    .line 67108984
    .line 67108985
    .line 67108986
    move-result-object v0

    .line 67108987
    invoke-static {v0}, LX/DTv;->LJ(Ljava/lang/String;)Ljava/lang/String;

    .line 67108988
    .line 67108989
    .line 67108990
    move-result-object v1

    .line 67108991
    const-string v0, "_data"

    .line 67108992
    .line 67108993
    invoke-virtual {v3, v0, v1}, Landroid/content/ContentValues;->put(Ljava/lang/String;Ljava/lang/String;)V

    .line 67108994
    .line 67108995
    .line 67108996
    goto :goto_0

    .line 67108997
    :cond_2
    const/4 v0, 0x0

    .line 67108998
    return-object v0
.end method

.method public static LJFF(Landroid/content/Context;Ljava/lang/String;Ljava/lang/String;)Landroid/net/Uri;
    .locals 15

    .prologue
    .line 50331648
    invoke-static {}, LX/CLD;->LIZ()Ljava/lang/StringBuilder;

    .line 50331649
    .line 50331650
    .line 50331651
    move-result-object v1

    .line 50331652
    sget-object v0, Landroid/os/Environment;->DIRECTORY_DCIM:Ljava/lang/String;

    .line 50331653
    .line 50331654
    invoke-virtual {v1, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    .line 50331655
    .line 50331656
    .line 50331657
    const-string v0, "/Camera/"

    .line 50331658
    .line 50331659
    invoke-virtual {v1, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    .line 50331660
    .line 50331661
    .line 50331662
    invoke-static {v1}, LX/CLD;->LIZIZ(Ljava/lang/StringBuilder;)Ljava/lang/String;

    .line 50331663
    .line 50331664
    .line 50331665
    move-result-object v7

    .line 50331666
    const/4 v14, 0x0

    .line 50331667
    if-eqz p0, :cond_c

    .line 50331668
    .line 50331669
    move-object/from16 v6, p1

    .line 50331670
    .line 50331671
    invoke-static {v6}, Landroid/text/TextUtils;->isEmpty(Ljava/lang/CharSequence;)Z

    .line 50331672
    .line 50331673
    .line 50331674
    move-result v0

    .line 50331675
    if-nez v0, :cond_c

    .line 50331676
    .line 50331677
    invoke-static {v7}, Landroid/text/TextUtils;->isEmpty(Ljava/lang/CharSequence;)Z

    .line 50331678
    .line 50331679
    .line 50331680
    move-result v0

    .line 50331681
    if-nez v0, :cond_c

    .line 50331682
    .line 50331683
    const-string v2, "/"

    .line 50331684
    .line 50331685
    invoke-virtual {v7, v2}, Ljava/lang/String;->endsWith(Ljava/lang/String;)Z

    .line 50331686
    .line 50331687
    .line 50331688
    move-result v0

    .line 50331689
    if-nez v0, :cond_0

    .line 50331690
    .line 50331691
    invoke-static {}, LX/CLD;->LIZ()Ljava/lang/StringBuilder;

    .line 50331692
    .line 50331693
    .line 50331694
    move-result-object v0

    .line 50331695
    invoke-virtual {v0, v7}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    .line 50331696
    .line 50331697
    .line 50331698
    invoke-virtual {v0, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    .line 50331699
    .line 50331700
    .line 50331701
    invoke-static {v0}, LX/CLD;->LIZIZ(Ljava/lang/StringBuilder;)Ljava/lang/String;

    .line 50331702
    .line 50331703
    .line 50331704
    move-result-object v7

    .line 50331705
    :cond_0
    sget-object v10, Landroid/provider/MediaStore$Images$Media;->EXTERNAL_CONTENT_URI:Landroid/net/Uri;

    .line 50331706
    .line 50331707
    invoke-static {}, LX/DTv;->LIZLLL()Z

    .line 50331708
    .line 50331709
    .line 50331710
    move-result v0

    .line 50331711
    if-eqz v0, :cond_1

    .line 50331712
    .line 50331713
    const-string v0, "external_primary"

    .line 50331714
    .line 50331715
    invoke-static {v0}, Landroid/provider/MediaStore$Images$Media;->getContentUri(Ljava/lang/String;)Landroid/net/Uri;

    .line 50331716
    .line 50331717
    .line 50331718
    move-result-object v10

    .line 50331719
    :cond_1
    :try_start_0
    invoke-static {}, LX/CLD;->LIZ()Ljava/lang/StringBuilder;

    .line 50331720
    .line 50331721
    .line 50331722
    move-result-object v1

    .line 50331723
    invoke-static {}, LX/bFn;->H()Ljava/io/File;

    .line 50331724
    .line 50331725
    .line 50331726
    move-result-object v0

    .line 50331727
    invoke-virtual {v0}, Ljava/io/File;->getPath()Ljava/lang/String;

    .line 50331728
    .line 50331729
    .line 50331730
    move-result-object v0

    .line 50331731
    invoke-virtual {v1, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    .line 50331732
    .line 50331733
    .line 50331734
    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    .line 50331735
    .line 50331736
    .line 50331737
    invoke-virtual {v1, v7}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    .line 50331738
    .line 50331739
    .line 50331740
    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    .line 50331741
    .line 50331742
    .line 50331743
    invoke-virtual {v1, v6}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    .line 50331744
    .line 50331745
    .line 50331746
    invoke-static {v1}, LX/CLD;->LIZIZ(Ljava/lang/StringBuilder;)Ljava/lang/String;

    .line 50331747
    .line 50331748
    .line 50331749
    move-result-object v0

    .line 50331750
    invoke-static {v0}, LX/DTv;->LJ(Ljava/lang/String;)Ljava/lang/String;

    .line 50331751
    .line 50331752
    .line 50331753
    move-result-object v1

    .line 50331754
    invoke-static {}, LX/DTv;->LIZLLL()Z

    .line 50331755
    .line 50331756
    .line 50331757
    move-result v0
    :try_end_0
    .catchall {:try_start_0 .. :try_end_0} :catchall_0

    .line 50331758
    const/4 v4, 0x0

    .line 50331759
    const-string v5, "mime_type"

    .line 50331760
    .line 50331761
    const/4 v3, 0x1

    .line 50331762
    const-string v2, "_id"

    .line 50331763
    .line 50331764
    if-eqz v0, :cond_2

    .line 50331765
    .line 50331766
    :try_start_1
    const-string v8, "(relative_path=? OR relative_path=?) AND _display_name=?"

    .line 50331767
    .line 50331768
    const/4 v0, 0x3

    .line 50331769
    new-array v1, v0, [Ljava/lang/String;

    .line 50331770
    .line 50331771
    aput-object v7, v1, v4

    .line 50331772
    .line 50331773
    invoke-virtual {v7}, Ljava/lang/String;->length()I

    .line 50331774
    .line 50331775
    .line 50331776
    move-result v0

    .line 50331777
    sub-int/2addr v0, v3

    .line 50331778
    invoke-virtual {v7, v4, v0}, Ljava/lang/String;->substring(II)Ljava/lang/String;

    .line 50331779
    .line 50331780
    .line 50331781
    move-result-object v0

    .line 50331782
    aput-object v0, v1, v3

    .line 50331783
    .line 50331784
    const/4 v0, 0x2

    .line 50331785
    aput-object v6, v1, v0

    .line 50331786
    .line 50331787
    invoke-virtual {p0}, Landroid/content/Context;->getContentResolver()Landroid/content/ContentResolver;

    .line 50331788
    .line 50331789
    .line 50331790
    move-result-object v7

    .line 50331791
    filled-new-array {v2, v5}, [Ljava/lang/String;

    .line 50331792
    .line 50331793
    .line 50331794
    move-result-object v6

    .line 50331795
    const/4 v0, -0x1

    .line 50331796
    invoke-static {v0, v4, v8, v14, v1}, LX/DTv;->LIZJ(IILjava/lang/String;Ljava/lang/String;[Ljava/lang/String;)Landroid/os/Bundle;

    .line 50331797
    .line 50331798
    .line 50331799
    move-result-object v1

    .line 50331800
    const-string v0, "diZqWQY7UcnZG14uCzCAS+5JiCtXksBJC4D4PYtE"

    .line 50331801
    .line 50331802
    invoke-static {v7, v10, v6, v1, v0}, LX/OZL;->LJIJI(Landroid/content/ContentResolver;Landroid/net/Uri;[Ljava/lang/String;Landroid/os/Bundle;Ljava/lang/String;)Landroid/database/Cursor;

    .line 50331803
    .line 50331804
    .line 50331805
    move-result-object v6

    .line 50331806
    goto :goto_0

    .line 50331807
    :cond_2
    invoke-virtual {p0}, Landroid/content/Context;->getContentResolver()Landroid/content/ContentResolver;

    .line 50331808
    .line 50331809
    .line 50331810
    move-result-object v9

    .line 50331811
    filled-new-array {v2, v5}, [Ljava/lang/String;

    .line 50331812
    .line 50331813
    .line 50331814
    move-result-object v11

    .line 50331815
    const-string v12, "_data=?"

    .line 50331816
    .line 50331817
    new-array v13, v3, [Ljava/lang/String;

    .line 50331818
    .line 50331819
    aput-object v1, v13, v4

    .line 50331820
    .line 50331821
    const-string p0, "diZqWQY7UcnZG14uCzCAS+5JiCtXksBJC4D4PYtE"

    .line 50331822
    .line 50331823
    invoke-static/range {v9 .. v15}, LX/OZL;->LJIJJLI(Landroid/content/ContentResolver;Landroid/net/Uri;[Ljava/lang/String;Ljava/lang/String;[Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)Landroid/database/Cursor;

    .line 50331824
    .line 50331825
    .line 50331826
    move-result-object v6

    .line 50331827
    :goto_0
    if-eqz v6, :cond_9
    :try_end_1
    .catchall {:try_start_1 .. :try_end_1} :catchall_0

    .line 50331828
    .line 50331829
    :try_start_2
    invoke-interface {v6}, Landroid/database/Cursor;->moveToFirst()Z

    .line 50331830
    .line 50331831
    .line 50331832
    move-result v0

    .line 50331833
    if-eqz v0, :cond_9

    .line 50331834
    .line 50331835
    new-instance v7, Ljava/util/ArrayList;

    .line 50331836
    .line 50331837
    invoke-direct {v7}, Ljava/util/ArrayList;-><init>()V

    .line 50331838
    .line 50331839
    .line 50331840
    new-instance v8, Lbytedance/io/BdMediaItem;

    .line 50331841
    .line 50331842
    invoke-direct {v8}, Lbytedance/io/BdMediaItem;-><init>()V

    .line 50331843
    .line 50331844
    .line 50331845
    invoke-interface {v6, v5}, Landroid/database/Cursor;->getColumnIndexOrThrow(Ljava/lang/String;)I

    .line 50331846
    .line 50331847
    .line 50331848
    move-result v0

    .line 50331849
    invoke-interface {v6, v0}, Landroid/database/Cursor;->getString(I)Ljava/lang/String;

    .line 50331850
    .line 50331851
    .line 50331852
    move-result-object v0

    .line 50331853
    iput-object v0, v8, Lbytedance/io/BdMediaItem;->mimeType:Ljava/lang/String;

    .line 50331854
    .line 50331855
    invoke-interface {v6, v2}, Landroid/database/Cursor;->getColumnIndexOrThrow(Ljava/lang/String;)I

    .line 50331856
    .line 50331857
    .line 50331858
    move-result v0

    .line 50331859
    invoke-interface {v6, v0}, Landroid/database/Cursor;->getLong(I)J

    .line 50331860
    .line 50331861
    .line 50331862
    move-result-wide v0

    .line 50331863
    invoke-static {v10, v0, v1}, Landroid/content/ContentUris;->withAppendedId(Landroid/net/Uri;J)Landroid/net/Uri;

    .line 50331864
    .line 50331865
    .line 50331866
    move-result-object v0

    .line 50331867
    iput-object v0, v8, Lbytedance/io/BdMediaItem;->uri:Landroid/net/Uri;

    .line 50331868
    .line 50331869
    invoke-virtual {v7, v8}, Ljava/util/ArrayList;->add(Ljava/lang/Object;)Z

    .line 50331870
    .line 50331871
    .line 50331872
    :goto_1
    invoke-interface {v6}, Landroid/database/Cursor;->moveToNext()Z

    .line 50331873
    .line 50331874
    .line 50331875
    move-result v0

    .line 50331876
    if-eqz v0, :cond_3

    .line 50331877
    .line 50331878
    new-instance v9, Lbytedance/io/BdMediaItem;

    .line 50331879
    .line 50331880
    invoke-direct {v9}, Lbytedance/io/BdMediaItem;-><init>()V

    .line 50331881
    .line 50331882
    .line 50331883
    invoke-interface {v6, v5}, Landroid/database/Cursor;->getColumnIndexOrThrow(Ljava/lang/String;)I

    .line 50331884
    .line 50331885
    .line 50331886
    move-result v0

    .line 50331887
    invoke-interface {v6, v0}, Landroid/database/Cursor;->getString(I)Ljava/lang/String;

    .line 50331888
    .line 50331889
    .line 50331890
    move-result-object v0

    .line 50331891
    iput-object v0, v8, Lbytedance/io/BdMediaItem;->mimeType:Ljava/lang/String;

    .line 50331892
    .line 50331893
    invoke-interface {v6, v2}, Landroid/database/Cursor;->getColumnIndexOrThrow(Ljava/lang/String;)I

    .line 50331894
    .line 50331895
    .line 50331896
    move-result v0

    .line 50331897
    invoke-interface {v6, v0}, Landroid/database/Cursor;->getLong(I)J

    .line 50331898
    .line 50331899
    .line 50331900
    move-result-wide v0

    .line 50331901
    invoke-static {v10, v0, v1}, Landroid/content/ContentUris;->withAppendedId(Landroid/net/Uri;J)Landroid/net/Uri;

    .line 50331902
    .line 50331903
    .line 50331904
    move-result-object v0

    .line 50331905
    iput-object v0, v8, Lbytedance/io/BdMediaItem;->uri:Landroid/net/Uri;

    .line 50331906
    .line 50331907
    invoke-virtual {v7, v9}, Ljava/util/ArrayList;->add(Ljava/lang/Object;)Z

    .line 50331908
    .line 50331909
    .line 50331910
    goto :goto_1

    .line 50331911
    :cond_3
    invoke-virtual {v7}, Ljava/util/ArrayList;->size()I

    .line 50331912
    .line 50331913
    .line 50331914
    move-result v0
    :try_end_2
    .catchall {:try_start_2 .. :try_end_2} :catchall_1

    .line 50331915
    const-string v8, ", actual mimetype is "

    .line 50331916
    .line 50331917
    const-string v5, "Except mimetype is "

    .line 50331918
    .line 50331919
    const-string v10, "image/*"

    .line 50331920
    .line 50331921
    move-object/from16 v9, p2

    .line 50331922
    .line 50331923
    if-ne v0, v3, :cond_5

    .line 50331924
    .line 50331925
    :try_start_3
    invoke-static {v9}, Landroid/text/TextUtils;->isEmpty(Ljava/lang/CharSequence;)Z

    .line 50331926
    .line 50331927
    .line 50331928
    move-result v0

    .line 50331929
    if-nez v0, :cond_4

    .line 50331930
    .line 50331931
    invoke-virtual {v10, v9}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    .line 50331932
    .line 50331933
    .line 50331934
    move-result v0

    .line 50331935
    if-nez v0, :cond_4

    .line 50331936
    .line 50331937
    invoke-virtual {v7, v4}, Ljava/util/ArrayList;->get(I)Ljava/lang/Object;

    .line 50331938
    .line 50331939
    .line 50331940
    move-result-object v0

    .line 50331941
    check-cast v0, Lbytedance/io/BdMediaItem;

    .line 50331942
    .line 50331943
    iget-object v0, v0, Lbytedance/io/BdMediaItem;->mimeType:Ljava/lang/String;

    .line 50331944
    .line 50331945
    invoke-virtual {v9, v0}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    .line 50331946
    .line 50331947
    .line 50331948
    move-result v0

    .line 50331949
    if-nez v0, :cond_4

    .line 50331950
    .line 50331951
    new-instance v2, Ljava/lang/IllegalArgumentException;

    .line 50331952
    .line 50331953
    invoke-static {}, LX/CLD;->LIZ()Ljava/lang/StringBuilder;

    .line 50331954
    .line 50331955
    .line 50331956
    move-result-object v1

    .line 50331957
    invoke-virtual {v1, v5}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    .line 50331958
    .line 50331959
    .line 50331960
    invoke-virtual {v1, v9}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    .line 50331961
    .line 50331962
    .line 50331963
    invoke-virtual {v1, v8}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    .line 50331964
    .line 50331965
    .line 50331966
    invoke-virtual {v7, v4}, Ljava/util/ArrayList;->get(I)Ljava/lang/Object;

    .line 50331967
    .line 50331968
    .line 50331969
    move-result-object v0

    .line 50331970
    check-cast v0, Lbytedance/io/BdMediaItem;

    .line 50331971
    .line 50331972
    iget-object v0, v0, Lbytedance/io/BdMediaItem;->mimeType:Ljava/lang/String;

    .line 50331973
    .line 50331974
    invoke-virtual {v1, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    .line 50331975
    .line 50331976
    .line 50331977
    invoke-static {v1}, LX/CLD;->LIZIZ(Ljava/lang/StringBuilder;)Ljava/lang/String;

    .line 50331978
    .line 50331979
    .line 50331980
    move-result-object v0

    .line 50331981
    invoke-direct {v2, v0}, Ljava/lang/IllegalArgumentException;-><init>(Ljava/lang/String;)V

    .line 50331982
    .line 50331983
    .line 50331984
    throw v2

    .line 50331985
    :cond_4
    invoke-virtual {v7, v4}, Ljava/util/ArrayList;->get(I)Ljava/lang/Object;

    .line 50331986
    .line 50331987
    .line 50331988
    move-result-object v0

    .line 50331989
    check-cast v0, Lbytedance/io/BdMediaItem;

    .line 50331990
    .line 50331991
    iget-object v14, v0, Lbytedance/io/BdMediaItem;->uri:Landroid/net/Uri;

    .line 50331992
    .line 50331993
    goto :goto_2

    .line 50331994
    :cond_5
    invoke-virtual {v7}, Ljava/util/ArrayList;->iterator()Ljava/util/Iterator;

    .line 50331995
    .line 50331996
    .line 50331997
    move-result-object v2

    .line 50331998
    :cond_6
    invoke-interface {v2}, Ljava/util/Iterator;->hasNext()Z

    .line 50331999
    .line 50332000
    .line 50332001
    move-result v0

    .line 50332002
    if-eqz v0, :cond_8

    .line 50332003
    .line 50332004
    invoke-interface {v2}, Ljava/util/Iterator;->next()Ljava/lang/Object;

    .line 50332005
    .line 50332006
    .line 50332007
    move-result-object v1

    .line 50332008
    check-cast v1, Lbytedance/io/BdMediaItem;

    .line 50332009
    .line 50332010
    invoke-static {v9}, Landroid/text/TextUtils;->isEmpty(Ljava/lang/CharSequence;)Z

    .line 50332011
    .line 50332012
    .line 50332013
    move-result v0

    .line 50332014
    if-nez v0, :cond_7

    .line 50332015
    .line 50332016
    invoke-virtual {v10, v9}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    .line 50332017
    .line 50332018
    .line 50332019
    move-result v0

    .line 50332020
    if-nez v0, :cond_7

    .line 50332021
    .line 50332022
    iget-object v0, v1, Lbytedance/io/BdMediaItem;->mimeType:Ljava/lang/String;

    .line 50332023
    .line 50332024
    invoke-virtual {v9, v0}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    .line 50332025
    .line 50332026
    .line 50332027
    move-result v0

    .line 50332028
    if-eqz v0, :cond_6

    .line 50332029
    .line 50332030
    :cond_7
    iget-object v14, v1, Lbytedance/io/BdMediaItem;->uri:Landroid/net/Uri;

    .line 50332031
    .line 50332032
    :cond_8
    if-nez v14, :cond_a

    .line 50332033
    .line 50332034
    new-instance v2, Ljava/lang/IllegalArgumentException;

    .line 50332035
    .line 50332036
    invoke-static {}, LX/CLD;->LIZ()Ljava/lang/StringBuilder;

    .line 50332037
    .line 50332038
    .line 50332039
    move-result-object v1

    .line 50332040
    invoke-virtual {v1, v5}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    .line 50332041
    .line 50332042
    .line 50332043
    invoke-virtual {v1, v9}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    .line 50332044
    .line 50332045
    .line 50332046
    invoke-virtual {v1, v8}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    .line 50332047
    .line 50332048
    .line 50332049
    invoke-virtual {v7, v4}, Ljava/util/ArrayList;->get(I)Ljava/lang/Object;

    .line 50332050
    .line 50332051
    .line 50332052
    move-result-object v0

    .line 50332053
    check-cast v0, Lbytedance/io/BdMediaItem;

    .line 50332054
    .line 50332055
    iget-object v0, v0, Lbytedance/io/BdMediaItem;->mimeType:Ljava/lang/String;

    .line 50332056
    .line 50332057
    invoke-virtual {v1, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    .line 50332058
    .line 50332059
    .line 50332060
    invoke-static {v1}, LX/CLD;->LIZIZ(Ljava/lang/StringBuilder;)Ljava/lang/String;

    .line 50332061
    .line 50332062
    .line 50332063
    move-result-object v0

    .line 50332064
    invoke-direct {v2, v0}, Ljava/lang/IllegalArgumentException;-><init>(Ljava/lang/String;)V

    .line 50332065
    .line 50332066
    .line 50332067
    throw v2

    .line 50332068
    :cond_9
    if-eqz v6, :cond_c
    :try_end_3
    .catchall {:try_start_3 .. :try_end_3} :catchall_1

    .line 50332069
    .line 50332070
    :cond_a
    :goto_2
    invoke-interface {v6}, Landroid/database/Cursor;->close()V

    .line 50332071
    .line 50332072
    .line 50332073
    return-object v14

    .line 50332074
    :catchall_0
    move-exception v0

    .line 50332075
    goto :goto_3

    .line 50332076
    :catchall_1
    move-exception v0

    .line 50332077
    move-object v14, v6

    .line 50332078
    :goto_3
    if-eqz v14, :cond_b

    .line 50332079
    .line 50332080
    invoke-interface {v14}, Landroid/database/Cursor;->close()V

    .line 50332081
    .line 50332082
    .line 50332083
    :cond_b
    throw v0

    .line 50332084
    :cond_c
    return-object v14
.end method

.method public static LJI(Landroid/content/Context;Landroid/net/Uri;)J
    .locals 4

    .prologue
    .line 33554432
    invoke-virtual {p1}, Landroid/net/Uri;->getScheme()Ljava/lang/String;

    .line 33554433
    .line 33554434
    .line 33554435
    move-result-object v1

    .line 33554436
    const-string v0, "file"

    .line 33554437
    .line 33554438
    invoke-virtual {v0, v1}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    .line 33554439
    .line 33554440
    .line 33554441
    move-result v0

    .line 33554442
    if-eqz v0, :cond_0

    .line 33554443
    .line 33554444
    new-instance v1, Ljava/io/File;

    .line 33554445
    .line 33554446
    invoke-virtual {p1}, Landroid/net/Uri;->getPath()Ljava/lang/String;

    .line 33554447
    .line 33554448
    .line 33554449
    move-result-object v0

    .line 33554450
    invoke-direct {v1, v0}, Ljava/io/File;-><init>(Ljava/lang/String;)V

    .line 33554451
    .line 33554452
    .line 33554453
    invoke-virtual {v1}, Ljava/io/File;->length()J

    .line 33554454
    .line 33554455
    .line 33554456
    move-result-wide v0

    .line 33554457
    return-wide v0

    .line 33554458
    :cond_0
    const-string v1, "content"

    .line 33554459
    .line 33554460
    invoke-virtual {p1}, Landroid/net/Uri;->getScheme()Ljava/lang/String;

    .line 33554461
    .line 33554462
    .line 33554463
    move-result-object v0

    .line 33554464
    invoke-virtual {v1, v0}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    .line 33554465
    .line 33554466
    .line 33554467
    move-result v0

    .line 33554468
    const-wide/16 v2, 0x0

    .line 33554469
    .line 33554470
    if-eqz v0, :cond_1

    .line 33554471
    .line 33554472
    :try_start_0
    invoke-virtual {p0}, Landroid/content/Context;->getContentResolver()Landroid/content/ContentResolver;

    .line 33554473
    .line 33554474
    .line 33554475
    move-result-object v1

    .line 33554476
    const-string v0, "r"

    .line 33554477
    .line 33554478
    invoke-virtual {v1, p1, v0}, Landroid/content/ContentResolver;->openFileDescriptor(Landroid/net/Uri;Ljava/lang/String;)Landroid/os/ParcelFileDescriptor;

    .line 33554479
    .line 33554480
    .line 33554481
    move-result-object v0

    .line 33554482
    invoke-virtual {v0}, Landroid/os/ParcelFileDescriptor;->getStatSize()J

    .line 33554483
    .line 33554484
    .line 33554485
    move-result-wide v0

    .line 33554486
    return-wide v0
    :try_end_0
    .catch Ljava/lang/Exception; {:try_start_0 .. :try_end_0} :catch_0

    .line 33554487
    :catch_0
    :cond_1
    return-wide v2
.end method

.method public static LJII(Landroid/content/Context;Ljava/lang/String;)Landroid/net/Uri;
    .locals 14

    .prologue
    .line 33554432
    invoke-static {}, LX/CLD;->LIZ()Ljava/lang/StringBuilder;

    .line 33554433
    .line 33554434
    .line 33554435
    move-result-object v1

    .line 33554436
    sget-object v0, Landroid/os/Environment;->DIRECTORY_DCIM:Ljava/lang/String;

    .line 33554437
    .line 33554438
    invoke-virtual {v1, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    .line 33554439
    .line 33554440
    .line 33554441
    const-string v0, "/Camera/"

    .line 33554442
    .line 33554443
    invoke-virtual {v1, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    .line 33554444
    .line 33554445
    .line 33554446
    invoke-static {v1}, LX/CLD;->LIZIZ(Ljava/lang/StringBuilder;)Ljava/lang/String;

    .line 33554447
    .line 33554448
    .line 33554449
    move-result-object v6

    .line 33554450
    const-string v2, "/"

    .line 33554451
    .line 33554452
    const/4 v13, 0x0

    .line 33554453
    if-eqz p0, :cond_a

    .line 33554454
    .line 33554455
    invoke-static {p1}, Landroid/text/TextUtils;->isEmpty(Ljava/lang/CharSequence;)Z

    .line 33554456
    .line 33554457
    .line 33554458
    move-result v0

    .line 33554459
    if-nez v0, :cond_a

    .line 33554460
    .line 33554461
    invoke-static {v6}, Landroid/text/TextUtils;->isEmpty(Ljava/lang/CharSequence;)Z

    .line 33554462
    .line 33554463
    .line 33554464
    move-result v0

    .line 33554465
    if-nez v0, :cond_a

    .line 33554466
    .line 33554467
    sget-object v9, Landroid/provider/MediaStore$Video$Media;->EXTERNAL_CONTENT_URI:Landroid/net/Uri;

    .line 33554468
    .line 33554469
    invoke-static {}, LX/DTv;->LIZLLL()Z

    .line 33554470
    .line 33554471
    .line 33554472
    move-result v0

    .line 33554473
    if-eqz v0, :cond_0

    .line 33554474
    .line 33554475
    const-string v0, "external_primary"

    .line 33554476
    .line 33554477
    invoke-static {v0}, Landroid/provider/MediaStore$Video$Media;->getContentUri(Ljava/lang/String;)Landroid/net/Uri;

    .line 33554478
    .line 33554479
    .line 33554480
    move-result-object v9

    .line 33554481
    :cond_0
    :try_start_0
    invoke-static {}, LX/CLD;->LIZ()Ljava/lang/StringBuilder;

    .line 33554482
    .line 33554483
    .line 33554484
    move-result-object v1

    .line 33554485
    invoke-static {}, LX/bFn;->H()Ljava/io/File;

    .line 33554486
    .line 33554487
    .line 33554488
    move-result-object v0

    .line 33554489
    invoke-virtual {v0}, Ljava/io/File;->getPath()Ljava/lang/String;

    .line 33554490
    .line 33554491
    .line 33554492
    move-result-object v0

    .line 33554493
    invoke-virtual {v1, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    .line 33554494
    .line 33554495
    .line 33554496
    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    .line 33554497
    .line 33554498
    .line 33554499
    invoke-virtual {v1, v6}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    .line 33554500
    .line 33554501
    .line 33554502
    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    .line 33554503
    .line 33554504
    .line 33554505
    invoke-virtual {v1, p1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    .line 33554506
    .line 33554507
    .line 33554508
    invoke-static {v1}, LX/CLD;->LIZIZ(Ljava/lang/StringBuilder;)Ljava/lang/String;

    .line 33554509
    .line 33554510
    .line 33554511
    move-result-object v0

    .line 33554512
    invoke-static {v0}, LX/DTv;->LJ(Ljava/lang/String;)Ljava/lang/String;

    .line 33554513
    .line 33554514
    .line 33554515
    move-result-object v1

    .line 33554516
    invoke-static {}, LX/DTv;->LIZLLL()Z

    .line 33554517
    .line 33554518
    .line 33554519
    move-result v0
    :try_end_0
    .catchall {:try_start_0 .. :try_end_0} :catchall_0

    .line 33554520
    const/4 v4, 0x0

    .line 33554521
    const-string v5, "mime_type"

    .line 33554522
    .line 33554523
    const/4 v3, 0x1

    .line 33554524
    const-string v2, "_id"

    .line 33554525
    .line 33554526
    if-eqz v0, :cond_1

    .line 33554527
    .line 33554528
    :try_start_1
    const-string v8, "(relative_path=? OR relative_path=?) AND _display_name=?"

    .line 33554529
    .line 33554530
    const/4 v0, 0x3

    .line 33554531
    new-array v1, v0, [Ljava/lang/String;

    .line 33554532
    .line 33554533
    aput-object v6, v1, v4

    .line 33554534
    .line 33554535
    invoke-virtual {v6}, Ljava/lang/String;->length()I

    .line 33554536
    .line 33554537
    .line 33554538
    move-result v0

    .line 33554539
    sub-int/2addr v0, v3

    .line 33554540
    invoke-virtual {v6, v4, v0}, Ljava/lang/String;->substring(II)Ljava/lang/String;

    .line 33554541
    .line 33554542
    .line 33554543
    move-result-object v0

    .line 33554544
    aput-object v0, v1, v3

    .line 33554545
    .line 33554546
    const/4 v0, 0x2

    .line 33554547
    aput-object p1, v1, v0

    .line 33554548
    .line 33554549
    invoke-virtual {p0}, Landroid/content/Context;->getContentResolver()Landroid/content/ContentResolver;

    .line 33554550
    .line 33554551
    .line 33554552
    move-result-object v7

    .line 33554553
    filled-new-array {v2, v5}, [Ljava/lang/String;

    .line 33554554
    .line 33554555
    .line 33554556
    move-result-object v6

    .line 33554557
    const/4 v0, -0x1

    .line 33554558
    invoke-static {v0, v4, v8, v13, v1}, LX/DTv;->LIZJ(IILjava/lang/String;Ljava/lang/String;[Ljava/lang/String;)Landroid/os/Bundle;

    .line 33554559
    .line 33554560
    .line 33554561
    move-result-object v1

    .line 33554562
    const-string v0, "diZqWQY7UcnZG14uCzCAS+5JiCtXksBJC4D4PYtE"

    .line 33554563
    .line 33554564
    invoke-static {v7, v9, v6, v1, v0}, LX/OZL;->LJIJI(Landroid/content/ContentResolver;Landroid/net/Uri;[Ljava/lang/String;Landroid/os/Bundle;Ljava/lang/String;)Landroid/database/Cursor;

    .line 33554565
    .line 33554566
    .line 33554567
    move-result-object v6

    .line 33554568
    goto :goto_0

    .line 33554569
    :cond_1
    invoke-virtual {p0}, Landroid/content/Context;->getContentResolver()Landroid/content/ContentResolver;

    .line 33554570
    .line 33554571
    .line 33554572
    move-result-object v8

    .line 33554573
    filled-new-array {v2, v5}, [Ljava/lang/String;

    .line 33554574
    .line 33554575
    .line 33554576
    move-result-object v10

    .line 33554577
    const-string v11, "_data=?"

    .line 33554578
    .line 33554579
    new-array v12, v3, [Ljava/lang/String;

    .line 33554580
    .line 33554581
    aput-object v1, v12, v4

    .line 33554582
    .line 33554583
    const-string p0, "diZqWQY7UcnZG14uCzCAS+5JiCtXksBJC4D4PYtE"

    .line 33554584
    .line 33554585
    invoke-static/range {v8 .. v14}, LX/OZL;->LJIJJLI(Landroid/content/ContentResolver;Landroid/net/Uri;[Ljava/lang/String;Ljava/lang/String;[Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)Landroid/database/Cursor;

    .line 33554586
    .line 33554587
    .line 33554588
    move-result-object v6

    .line 33554589
    :goto_0
    if-eqz v6, :cond_7
    :try_end_1
    .catchall {:try_start_1 .. :try_end_1} :catchall_0

    .line 33554590
    .line 33554591
    :try_start_2
    invoke-interface {v6}, Landroid/database/Cursor;->moveToFirst()Z

    .line 33554592
    .line 33554593
    .line 33554594
    move-result v0

    .line 33554595
    if-eqz v0, :cond_7

    .line 33554596
    .line 33554597
    new-instance v7, Ljava/util/ArrayList;

    .line 33554598
    .line 33554599
    invoke-direct {v7}, Ljava/util/ArrayList;-><init>()V

    .line 33554600
    .line 33554601
    .line 33554602
    new-instance v8, Lbytedance/io/BdMediaItem;

    .line 33554603
    .line 33554604
    invoke-direct {v8}, Lbytedance/io/BdMediaItem;-><init>()V

    .line 33554605
    .line 33554606
    .line 33554607
    invoke-interface {v6, v5}, Landroid/database/Cursor;->getColumnIndexOrThrow(Ljava/lang/String;)I

    .line 33554608
    .line 33554609
    .line 33554610
    move-result v0

    .line 33554611
    invoke-interface {v6, v0}, Landroid/database/Cursor;->getString(I)Ljava/lang/String;

    .line 33554612
    .line 33554613
    .line 33554614
    move-result-object v0

    .line 33554615
    iput-object v0, v8, Lbytedance/io/BdMediaItem;->mimeType:Ljava/lang/String;

    .line 33554616
    .line 33554617
    invoke-interface {v6, v2}, Landroid/database/Cursor;->getColumnIndexOrThrow(Ljava/lang/String;)I

    .line 33554618
    .line 33554619
    .line 33554620
    move-result v0

    .line 33554621
    invoke-interface {v6, v0}, Landroid/database/Cursor;->getLong(I)J

    .line 33554622
    .line 33554623
    .line 33554624
    move-result-wide v0

    .line 33554625
    invoke-static {v9, v0, v1}, Landroid/content/ContentUris;->withAppendedId(Landroid/net/Uri;J)Landroid/net/Uri;

    .line 33554626
    .line 33554627
    .line 33554628
    move-result-object v0

    .line 33554629
    iput-object v0, v8, Lbytedance/io/BdMediaItem;->uri:Landroid/net/Uri;

    .line 33554630
    .line 33554631
    invoke-virtual {v7, v8}, Ljava/util/ArrayList;->add(Ljava/lang/Object;)Z

    .line 33554632
    .line 33554633
    .line 33554634
    :goto_1
    invoke-interface {v6}, Landroid/database/Cursor;->moveToNext()Z

    .line 33554635
    .line 33554636
    .line 33554637
    move-result v0

    .line 33554638
    if-eqz v0, :cond_2

    .line 33554639
    .line 33554640
    new-instance v8, Lbytedance/io/BdMediaItem;

    .line 33554641
    .line 33554642
    invoke-direct {v8}, Lbytedance/io/BdMediaItem;-><init>()V

    .line 33554643
    .line 33554644
    .line 33554645
    invoke-interface {v6, v5}, Landroid/database/Cursor;->getColumnIndexOrThrow(Ljava/lang/String;)I

    .line 33554646
    .line 33554647
    .line 33554648
    move-result v0

    .line 33554649
    invoke-interface {v6, v0}, Landroid/database/Cursor;->getString(I)Ljava/lang/String;

    .line 33554650
    .line 33554651
    .line 33554652
    move-result-object v0

    .line 33554653
    iput-object v0, v8, Lbytedance/io/BdMediaItem;->mimeType:Ljava/lang/String;

    .line 33554654
    .line 33554655
    invoke-interface {v6, v2}, Landroid/database/Cursor;->getColumnIndexOrThrow(Ljava/lang/String;)I

    .line 33554656
    .line 33554657
    .line 33554658
    move-result v0

    .line 33554659
    invoke-interface {v6, v0}, Landroid/database/Cursor;->getLong(I)J

    .line 33554660
    .line 33554661
    .line 33554662
    move-result-wide v0

    .line 33554663
    invoke-static {v9, v0, v1}, Landroid/content/ContentUris;->withAppendedId(Landroid/net/Uri;J)Landroid/net/Uri;

    .line 33554664
    .line 33554665
    .line 33554666
    move-result-object v0

    .line 33554667
    iput-object v0, v8, Lbytedance/io/BdMediaItem;->uri:Landroid/net/Uri;

    .line 33554668
    .line 33554669
    invoke-virtual {v7, v8}, Ljava/util/ArrayList;->add(Ljava/lang/Object;)Z

    .line 33554670
    .line 33554671
    .line 33554672
    goto :goto_1

    .line 33554673
    :cond_2
    invoke-virtual {v7}, Ljava/util/ArrayList;->size()I

    .line 33554674
    .line 33554675
    .line 33554676
    move-result v0
    :try_end_2
    .catchall {:try_start_2 .. :try_end_2} :catchall_1

    .line 33554677
    const-string v8, ", actual mimetype is "

    .line 33554678
    .line 33554679
    const-string v5, "Except mimetype is "

    .line 33554680
    .line 33554681
    const-string/jumbo v1, "video/*"

    .line 33554682
    .line 33554683
    .line 33554684
    if-ne v0, v3, :cond_4

    .line 33554685
    .line 33554686
    :try_start_3
    invoke-static {v13}, Landroid/text/TextUtils;->isEmpty(Ljava/lang/CharSequence;)Z

    .line 33554687
    .line 33554688
    .line 33554689
    move-result v0

    .line 33554690
    if-nez v0, :cond_3

    .line 33554691
    .line 33554692
    invoke-virtual {v1, v13}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    .line 33554693
    .line 33554694
    .line 33554695
    move-result v0

    .line 33554696
    if-nez v0, :cond_3

    .line 33554697
    .line 33554698
    invoke-virtual {v7, v4}, Ljava/util/ArrayList;->get(I)Ljava/lang/Object;

    .line 33554699
    .line 33554700
    .line 33554701
    move-result-object v0

    .line 33554702
    check-cast v0, Lbytedance/io/BdMediaItem;

    .line 33554703
    .line 33554704
    throw v13

    .line 33554705
    :cond_3
    invoke-virtual {v7, v4}, Ljava/util/ArrayList;->get(I)Ljava/lang/Object;

    .line 33554706
    .line 33554707
    .line 33554708
    move-result-object v0

    .line 33554709
    check-cast v0, Lbytedance/io/BdMediaItem;

    .line 33554710
    .line 33554711
    iget-object v0, v0, Lbytedance/io/BdMediaItem;->uri:Landroid/net/Uri;

    .line 33554712
    .line 33554713
    goto :goto_3

    .line 33554714
    :cond_4
    invoke-virtual {v7}, Ljava/util/ArrayList;->iterator()Ljava/util/Iterator;

    .line 33554715
    .line 33554716
    .line 33554717
    move-result-object v1

    .line 33554718
    invoke-interface {v1}, Ljava/util/Iterator;->hasNext()Z

    .line 33554719
    .line 33554720
    .line 33554721
    move-result v0

    .line 33554722
    if-eqz v0, :cond_6

    .line 33554723
    .line 33554724
    invoke-interface {v1}, Ljava/util/Iterator;->next()Ljava/lang/Object;

    .line 33554725
    .line 33554726
    .line 33554727
    move-result-object v1

    .line 33554728
    check-cast v1, Lbytedance/io/BdMediaItem;

    .line 33554729
    .line 33554730
    invoke-static {v13}, Landroid/text/TextUtils;->isEmpty(Ljava/lang/CharSequence;)Z

    .line 33554731
    .line 33554732
    .line 33554733
    move-result v0

    .line 33554734
    if-eqz v0, :cond_5

    .line 33554735
    .line 33554736
    iget-object v0, v1, Lbytedance/io/BdMediaItem;->uri:Landroid/net/Uri;

    .line 33554737
    .line 33554738
    goto :goto_2

    .line 33554739
    :cond_5
    throw v13

    .line 33554740
    :cond_6
    move-object v0, v13

    .line 33554741
    :goto_2
    if-nez v0, :cond_8

    .line 33554742
    .line 33554743
    new-instance v2, Ljava/lang/IllegalArgumentException;

    .line 33554744
    .line 33554745
    invoke-static {}, LX/CLD;->LIZ()Ljava/lang/StringBuilder;

    .line 33554746
    .line 33554747
    .line 33554748
    move-result-object v1

    .line 33554749
    invoke-virtual {v1, v5}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    .line 33554750
    .line 33554751
    .line 33554752
    invoke-virtual {v1, v13}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    .line 33554753
    .line 33554754
    .line 33554755
    invoke-virtual {v1, v8}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    .line 33554756
    .line 33554757
    .line 33554758
    invoke-virtual {v7, v4}, Ljava/util/ArrayList;->get(I)Ljava/lang/Object;

    .line 33554759
    .line 33554760
    .line 33554761
    move-result-object v0

    .line 33554762
    check-cast v0, Lbytedance/io/BdMediaItem;

    .line 33554763
    .line 33554764
    iget-object v0, v0, Lbytedance/io/BdMediaItem;->mimeType:Ljava/lang/String;

    .line 33554765
    .line 33554766
    invoke-virtual {v1, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    .line 33554767
    .line 33554768
    .line 33554769
    invoke-static {v1}, LX/CLD;->LIZIZ(Ljava/lang/StringBuilder;)Ljava/lang/String;

    .line 33554770
    .line 33554771
    .line 33554772
    move-result-object v0

    .line 33554773
    invoke-direct {v2, v0}, Ljava/lang/IllegalArgumentException;-><init>(Ljava/lang/String;)V

    .line 33554774
    .line 33554775
    .line 33554776
    throw v2

    .line 33554777
    :cond_7
    if-eqz v6, :cond_a

    .line 33554778
    .line 33554779
    goto :goto_4

    .line 33554780
    :cond_8
    :goto_3
    move-object v13, v0
    :try_end_3
    .catchall {:try_start_3 .. :try_end_3} :catchall_1

    .line 33554781
    :goto_4
    invoke-interface {v6}, Landroid/database/Cursor;->close()V

    .line 33554782
    .line 33554783
    .line 33554784
    return-object v13

    .line 33554785
    :catchall_0
    move-exception v0

    .line 33554786
    goto :goto_5

    .line 33554787
    :catchall_1
    move-exception v0

    .line 33554788
    move-object v13, v6

    .line 33554789
    :goto_5
    if-eqz v13, :cond_9

    .line 33554790
    .line 33554791
    invoke-interface {v13}, Landroid/database/Cursor;->close()V

    .line 33554792
    .line 33554793
    .line 33554794
    :cond_9
    throw v0

    .line 33554795
    :cond_a
    return-object v13
.end method

.method public static LJIIIIZZ(Landroid/content/Context;Landroid/net/Uri;)Z
    .locals 3

    .prologue
    .line 33554432
    const/4 v2, 0x0

    .line 33554433
    if-eqz p0, :cond_1

    .line 33554434
    .line 33554435
    if-eqz p1, :cond_1

    .line 33554436
    .line 33554437
    invoke-virtual {p0}, Landroid/content/Context;->getContentResolver()Landroid/content/ContentResolver;

    .line 33554438
    .line 33554439
    .line 33554440
    move-result-object v1

    .line 33554441
    :try_start_0
    const-string v0, "r"

    .line 33554442
    .line 33554443
    invoke-virtual {v1, p1, v0}, Landroid/content/ContentResolver;->openAssetFileDescriptor(Landroid/net/Uri;Ljava/lang/String;)Landroid/content/res/AssetFileDescriptor;

    .line 33554444
    .line 33554445
    .line 33554446
    move-result-object v0

    .line 33554447
    if-nez v0, :cond_0

    .line 33554448
    .line 33554449
    return v2
    :try_end_0
    .catch Ljava/io/FileNotFoundException; {:try_start_0 .. :try_end_0} :catch_1

    .line 33554450
    :cond_0
    :try_start_1
    invoke-virtual {v0}, Landroid/content/res/AssetFileDescriptor;->close()V
    :try_end_1
    .catch Ljava/io/IOException; {:try_start_1 .. :try_end_1} :catch_0

    .line 33554451
    .line 33554452
    .line 33554453
    :catch_0
    const/4 v0, 0x1

    .line 33554454
    return v0

    .line 33554455
    :catch_1
    :cond_1
    return v2
.end method

.method public static LJIIIZ(Landroid/content/Context;Ljava/lang/String;)V
    .locals 3

    .prologue
    .line 33554432
    new-instance v1, Landroid/content/Intent;

    .line 33554433
    .line 33554434
    const-string v0, "android.intent.action.MEDIA_SCANNER_SCAN_FILE"

    .line 33554435
    .line 33554436
    invoke-direct {v1, v0}, Landroid/content/Intent;-><init>(Ljava/lang/String;)V

    .line 33554437
    .line 33554438
    .line 33554439
    new-instance v0, Ljava/io/File;

    .line 33554440
    .line 33554441
    invoke-direct {v0, p1}, Ljava/io/File;-><init>(Ljava/lang/String;)V

    .line 33554442
    .line 33554443
    .line 33554444
    invoke-static {v0}, Landroid/net/Uri;->fromFile(Ljava/io/File;)Landroid/net/Uri;

    .line 33554445
    .line 33554446
    .line 33554447
    move-result-object v0

    .line 33554448
    invoke-virtual {v1, v0}, Landroid/content/Intent;->setData(Landroid/net/Uri;)Landroid/content/Intent;

    .line 33554449
    .line 33554450
    .line 33554451
    invoke-virtual {p0, v1}, Landroid/content/Context;->sendBroadcast(Landroid/content/Intent;)V

    .line 33554452
    .line 33554453
    .line 33554454
    const/4 v0, 0x1

    .line 33554455
    new-array v2, v0, [Ljava/lang/String;

    .line 33554456
    .line 33554457
    const/4 v0, 0x0

    .line 33554458
    aput-object p1, v2, v0

    .line 33554459
    .line 33554460
    const/4 v1, 0x0

    .line 33554461
    const-string v0, "diZqWQY7UcnZG14uCzCAS+5JiCtXksBJC4D4PYtE"

    .line 33554462
    .line 33554463
    invoke-static {p0, v2, v1, v1, v0}, LX/OZL;->LJJJJZ(Landroid/content/Context;[Ljava/lang/String;[Ljava/lang/String;LX/8Jp;Ljava/lang/String;)V

    .line 33554464
    .line 33554465
    .line 33554466
    return-void
.end method
