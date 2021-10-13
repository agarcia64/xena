#!/usr/bin/env bash

SPEC=0
PLAY=1
CLI=0

if [ $SPEC -eq 1 ]; then
    ansible localhost -m ceph_spec_bootstrap \
      -a "deployed_metalsmith=fake_workdir/deployed_metal.yaml \
          new_ceph_spec=fake_workdir/ceph_spec.yaml
          tripleo_roles=/usr/share/openstack-tripleo-heat-templates/roles/Standalone.yaml"
fi


if [ $PLAY -eq 1 ]; then
    PLAYBOOKS="/usr/share/ansible/tripleo-playbooks"
    THT="/usr/share/openstack-tripleo-heat-templates"
    INV="$PWD/fake_workdir/tripleo-ansible-inventory.yaml"
    ansible-playbook -i $INV \
           -v \
           $PLAYBOOKS/cli-deployed-ceph.yaml \
           -e baremetal_deployed_path="$PWD/fake_workdir/deployed_metal.yaml" \
           -e ceph_spec_path="$PWD/fake_workdir/ceph_spec.yaml" \
           -e deployed_ceph_tht_path="$PWD/deployed_ceph.yaml" \
           -e tripleo_roles_path="$THT/roles/Standalone.yaml" \
           -e tripleo_cephadm_container_image="daemon" \
           -e tripleo_cephadm_container_ns="quay.ceph.io/ceph-ci" \
           -e tripleo_cephadm_container_tag="latest-pacific-devel" \
           -e working_dir="$PWD/fake_workdir" \
           -e dynamic_ceph_spec="false" \
           -e storage_network_name="ctlplane" \
           -e storage_mgmt_network_name="ctlplane"
fi


if [ $CLI -eq 1 ]; then
    openstack overcloud ceph deploy \
          fake_workdir/deployed_metal.yaml \
          --working-dir fake_workdir \
          --roles-data /usr/share/openstack-tripleo-heat-templates/roles/Standalone.yaml \
          --osd-spec fake_workdir/osd_spec.yaml \
          --container-namespace quay.io/ceph \
          --container-image daemon \
          --container-tag v6.0.4-stable-6.0-pacific-centos-8-x86_64 \
          --stack standalone \
          -y -o deployed_ceph.yaml
fi
