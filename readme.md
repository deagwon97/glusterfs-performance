# Glusterfs 환경에서 병렬 파일 입출력 성능 분석

다양한 glusterfs 조합에서 파일 I/O 성능을 실험하기 위해 시작한 프로젝트 입니다. 자세한 설명은 아래 링크를 참고하시기 바랍니다.

[NFS에서 분산 파일 시스템 Glusterfs로 전환](https://deagwon.com/post/60)


## 실험 목적
다양한 glusterfs 볼륨별 다중 및 단일 파일 I/O 성능 분석

## 실험 환경
- Nodes: 8EA
- OS: Centos7
- CPU: Intel Xeon Gold 6240R 2.4GHz 48 cores
- Network Switch
    - QFX5210 SWITCH, jupyter
    - bandwidht: 40GBps
- HDD
    - RAID Controller: MegaRAID SAS-3 3108(64 bits width, 66MHz clock, 528 MB/s)
    - disk: INSPUR, AVAGO, 25TiB (27TB), ansiversion=5 logicalsectorsize=512 mount.fstype=xfs mount.options=rw,relatime,attr2,inode64,sunit=512,swidth=512,noquota sectorsize=4096 **24EA(3EA per nodes)**

## 실험 구성
- Distributed 8
- Disperse 8 (Redundancy 2)
- Distributed 4 Replicated 2
- Distributed 2 Disperse 4 (Redundancy 1)

## 실험 결과

|              | nfs            | distribute 8   | dispersed 8, redundancy 2 | distributed 2, dispersed 4, redundancy 1 | distributed 4, replicated 2 |
| ------------ | -------------- | -------------- | ------------------------- | ---------------------------------------- | --------------------------- |
| brick 수      | 1 (146 TB)     | 8 (204 TB)     | 8 (204 TB)                | 8 (204 TB)                               | 8 (204 TB)                  |
| 스토리지 용량      | 146 TB         | 204 TB         | 154 TB                    | 153 TB                                   | 102TB                       |
| 단일 파일        | 40 ~ 300 MBps  | 310 ~ 320 MB/s | 290 MB/s                  | 300 MB/s                                 | 290 MB/s                    |
| 다중 파일(8개 동시) | 300 ~ 600 MBps | 2.1 ~ 2.3 GB/s | 1.2 ~ 1.6 GB/s            | 1.5 ~ 1.8 GB/s                           | 1.1 ~ 1.7 GB/s              |

### 단일 파일 I/O
<img src="images/single-file.png"/>

### 다중 파일 I/O
<img src="images/multiple-file.png"/>


## reference
- https://docs.gluster.org/en/latest/
- https://access.redhat.com/documentation/en-us/red_hat_gluster_storage/3.1/html/administration_guide/chap-recommended-configuration_dispersed
- https://access.redhat.com/documentation/en-us/red_hat_gluster_storage/3.3/html/administration_guide/chap-red_hat_storage_volumes-creating_dispersed_volumes_1
- https://portal.nutanix.com/page/documents/kbs/details?targetId=kA07V0000004U9TSAU
- https://en.wikipedia.org/wiki/Named_pipe
- https://linuxhint.com/send-process-background-linux/
- https://man7.org/linux/man-pages/man1/dd.1.html
